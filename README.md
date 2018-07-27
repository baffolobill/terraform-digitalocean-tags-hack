# terraform-digitalocean-tags-hack
My dirty hack to solve (kind of) [Terraform DigitalOcean Tags problem](https://github.com/terraform-providers/terraform-provider-digitalocean/issues/7)


I'm sure all faced with that problem. Using `sort()` doesn't solve the problem, because DigitalOcean API returns tags in random? order. I even tried to sort them by their hash, but still got the same result.

In my case it's not a big deal to see changes in tags after each `terraform plan`. There is another big problem: when I add a new tag, Terraform destroys all existing tags and recreates them. It's impossible to use `lifecycle { prevent_destroy = yes }`, because you'll get an error: "... cannot destroy because of prevent_destroy is 'yes' ...".  
Why this is a huge problem - because when you delete a tag, this tag will be deleted from all resources, which uses it. As result, all your Firewall rules, service discovery (if uses tags for retry-join in Consul) and other things tied to DigitalOcean Tags won't work.

So, the solution is very obvious and simple - create tags via external script using DigitalOcean API. And this is what you'll find in this repo.

The disadvantage of this approach - you need to delete unused tags manually.

I commented important lines with "!!!".
