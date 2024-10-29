# tfc-stacks-demo

Demonstration for HCP Terraform Stacks

## Introduction

This repository is meant to demonstrate using the new Stacks feature on HCP Terraform. If you're new to Stacks, I recommend reading this article. If that's too much, the tl;dr is that Stack is basically Terragrunt on HCP Terraform. Is that oversimplifying? Probably. It's also not that far from the truth.

## Why Stacks?

Ah crap, here I go pontificating some more. You can skip this section if you don't care about the WHY and want to get to the HOW.

In the world of Terraform, a fairly common pattern has emerged regarding root modules. The root module has become the glue to link together one or more child modules that handle the actual infrastructure definitions. Consider an environment that has the following high-level components:

* Azure VM Scale-Set
* Azure Key Vault
* Network Security Group
* Azure Load Balancer

There are now Azure Verified Modules for many of these components, so your abbreviated root module might look something like this:

```hcl
provider "azurerm" {
    features {}
}


module "vmss" {
  source  = "Azure/avm-res-compute-virtualmachinescaleset/azurerm"
  version = "0.4.0"
  # insert the 5 required variables here
}



module "avm-res-keyvault-vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.9.1"
  # insert the 4 required variables here
}



module "avm-res-network-loadbalancer" {
  source  = "Azure/avm-res-network-loadbalancer/azurerm"
  version = "0.2.2"
  # insert the 4 required variables here
}



module "avm-res-network-networksecuritygroup" {
  for_each = var.nsgs
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.2.0"
  # insert the 3 required variables here
}

```

It's basically all module references with the root module simply defining the provider to be used, the input variables, and the outputs to be exposed.

This approach is great! It focuses on code reuse and lets you version and upgrade your modules as needed when new features arrive. If you're relatively new to Terraform and simply want to build out an infrastructure from lego bricks, this approach will make things easy for you. There's even a no-code module solution in HCP Terraform that removes the need to build the root module your self.

However, there are some problems with this approach:

* Defining and managing environments
* Sequencing deployments for unknown values
* Dynamically creating providers
* Larger state files
* Blast radius considerations

I don't want to get too mired in all this, but what the hell, it's my README and you're reading it.

### Defining and Managing Environments

Typically a root module is meant to manage a single environment. You could repeat the module blocks for every environment (dev, qa, prod, etc) you want to manage, but that leads to its own set of problems. First of all, your state file will get packed with resources that aren't related to each other. Second, any update to an environment will lock work on all environments till it's done. Assuming you don't use the same credentials/accounts/subscriptions for each environment, you'll need to create multiple instances of the providers for each environment. And finally, it's much harder to separate concerns and permissions for your teams when you co-mingle environments.

So the solution is to handle environments outside of Terraform. Maybe you use workspaces or code branches or a folder structure or something else, but the point is that environments are going to be handled through your automation solution and not by Terraform itself. It's also a big reason Terragrunt exists, because it provides exactly this type of abstraction as a wrapper around Terraform itself.

### Sequencing Deployments for Unknown Values

When Terraform is generating an execution plan, it uses the resource graph to determine the order in which resources need to be provisioned and uses the providers to talk to the target platforms to map out the deployment. However, there may be scenarios where one of the platforms you want to talk to doesn't exist yet, because another part of the configuration will be deploying it.

The canonical example is a Terraform configuration that deploys a Kubernetes cluster and then provisions things inside that cluster. During the first plan, Terraform cannot contact the cluster to plan the deployment because that cluster doesn't exist yet! So the plan will fail. The typical workaround is to use the `-target` flag to do a partial deployment. Or you could break the configuration up into two separate workspaces and sequence the deployment that way. Either way you're doing some custom scripting or automation outside of Terraform as there's no way to declarative tell Terraform to sequence the deployment in a certain way.

### Dynamically Creating Providers

There's two annoying thins about the `provider` block in Terraform. The first is simple and it's an artifact of how the language grew over time. When you create a new resource in Terraform it takes the form of:

```hcl
resource "resource_type" "resource_name" {}
```

And you can refer to that resource using the identifier: `resource_type.resource_name`.

When you create an instance of a provider, it takes the form:

```hcl
provider "azurerm" {}
```

Notice something different here? The provider has no block label for naming. If I had to guess, that's because early on in the design process, no one thought you'd need multiple instances of a single provider, so why include a name label?

Of course, we did eventually need multiple instances of a provider, and thus the `alias` argument was created:

```hcl
provider "azurerm" {
    alias = "east"
}
```

Now I don't know why the `alias` was added instead of simply using a name label. Seems... unnecessary. From a pure consistency approach, I would have preferred the name label. Not an insurmountable problem, but it does feel kludgey.

Of more impact was the decision not to support the `count` meta-argument and later the `for_each` meta-argument. Which means that every instance of the provider must be statically defined in the configuration. Want to use ten instances of the `azurerm` provider to work with ten subscriptions? Then you're adding ten `provider` blocks with different aliases. I'll admit this is a bit of an edge case, but still there have been open issues on GitHub for support the `count` or `for_each` meta-arguments for years.

Again, the solution is to build some custom scripting or automation outside of Terraform to deal with the limitation.

### Larger State Files

The more stuff you have in the root module, the bigger your state file gets. Old crusty Terraformers live in fear of a state file being corrupted, spelling a bad day for all involved. The actual risk of corruption has dropped precipitously since the pre-1.0 days. Instead, I think the major concern of a large state file is two-fold:

1. Big state files mean longer state refresh times
1. Big state files mean more people have access to sensitive data

Ideally you want to organize your state to group resources that are tightly coupled together, under management by a single team, and related to infrastructure with a common lifecycle.

When you break up a config, you are also breaking up the underlying state file. This is disruptive to dependency management, resource coupling, and resource references. Terraform only draws a resource graph that spans a single configuration, so it is only aware of dependencies that exist within that config. If you want to express an dependency outside of the configuration, you have to do so through data sources or outside of Terraform altogether. It is much simpler to keep all your resources in a single configuration, but then you have to deal with the problems of a large state file.

### Blast Radius Considerations

The more resources you have in a single configuration, the larger the blast radius if something goes wrong. You typically wouldn't want your shared networking resources to be in the same configuration as the resources for an application. If you did that, you'd need to give both your networking team and application team access to make changes to the config, and that means you application team can break networking for other applications. That seems... bad.

The suggested approach is to organize code by responsibility, lifecycle, and purpose. The code for shared networking resources lives in a repository managed by the networking team. The code for infrastructure that supports application A lives in a repository managed by the application A team.

Creating this separation does require that there is some amount of communication between related configurations. Application A probably need some information from the shared networking configuration, so you need some way of sharing that information and alerting application A when that information changes. The degree to which the two configurations are coupled will determine how you share that information.

Ultimately, reducing blast radius is about grouping resources responsibly, understanding the relationship between resources, and controlling who has access to change those resources.

## What Was I Saying?

Oh yeah, we were talking about Stacks! My original point was that building a complex configuration using the root module model has some drawbacks, and Stacks is one way of dealing with those drawbacks.

Terraform Stacks let you describe a set of components that comprise a stack and deployments that will use the stack to create resources. Think of a component as a layer, or what you would include in a Terraform child module. For an application, the components might be the front-end, backend, and database. A deployment is a single instance of the stack, which could be by environment tier, e.g. dev, prod, and qa. Or by location, e.g. east us, northern europe, and australia. Or both!

Within the stack definition, you can declaratively describe the relationship between components of the stack. 