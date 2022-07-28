/**
 * # Github Repository
 *
 * The Terraform configuration needs to update Github Action Variable 
 * This way we can manage secret and inventory automatically
 */
data "github_repository" "repo" {
  full_name = var.repo_name
}
resource "github_repository_environment" "multinode_environment" {
  repository       = data.github_repository.repo.name
  environment      = "multinode"
}
resource "github_actions_environment_secret" "test_secret" {
  repository       = data.github_repository.repo.name
  environment      = github_repository_environment.multinode_environment.environment
  secret_name      = "test_secret_name"
  plaintext_value  = "%s"
}
