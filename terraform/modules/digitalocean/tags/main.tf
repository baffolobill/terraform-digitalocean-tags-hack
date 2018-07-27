# ---------------------------------------------------------------------------------------------------------------------
# THESE TEMPLATES REQUIRE TERRAFORM VERSION 0.11.4 AND ABOVE
# ---------------------------------------------------------------------------------------------------------------------

terraform {
    required_version = ">= 0.11.4"
}

locals {
    tags_sorted = "${sort(distinct(var.tags))}"
}

resource "null_resource" "tags" {
    triggers {
        tag_ids = "${join(",", local.tags_sorted)}"
    }

    provisioner "local-exec" {
        command = "\"${path.module}/../../../../scripts/create_tags.sh\" ${join(" ", local.tags_sorted)}"
    }
}