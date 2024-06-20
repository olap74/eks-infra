# AWS K8S Infra deployment automation

This solution has been created to provide the ability to deploy ready to use EKS cluster(s) including most of required cluster tools. This solution uses Terraform and Terragrunt for deployment.

### Required software

- Terraform (v1.8.4)
- Terragrunt (v0.58.9)

## Structure and files

This solution has two directories in the root directory:
- `modules` - Terraform modules
- `providers` - Terragrunt configs

Terragrunt configs structure looks next: 
- `providers` - contains sub-directories for environments (*dev*,*stage*,*prod*, etc)
	- `ENV_NAME` - contains main `terragrunt.hcl` config and `account.hcl` for storing account-wide variables. Besides, it contains sub directories `general` - for account wide modules configs and regional directories named the same like AWS locations looks like (e.g.: `eu-north-1`, etc)
	    - `REGION_NAME` - contains `regional` directory for regional wide modules configs and directories that contains particular cluster modules configs (e.g.: `cluster-dev01`). Also it has `region.hcl` file that contains variables related to the region.
	        - `CLUSTER_NAME` - directory contains modules configuration, the directory named `eks-resources` that contains cluster tools modules deployment configs. Also, in this directory there is a file `env_vars.hcl` that contains cluster-wide variables.

## Preparation and Deployment

To deploy this solution the next files should be updated: 
- `terragrunt.hcl` - Terrafrom backend config
- `account.hcl` - Account wide variables
- `region.hcl` - Region wide variables
- `env_vars.hcl` - Cluster-related variables

When all variable files have been updated the deployment should be verified by running terragrunt in the environment directory (where main `terragrunt.hcl` file is located):

```
terragrunt run-all init
```
Then you should generate plans to be able to verify all resources that are going to be deployed:
```
terragrunt run-all plan
```

And after plan verification you can deploy all resources together running:
```
terragrunt run-all apply
```
In case of any issue, you can deploy modules one by one, but you should keep in mind that most of modules are dependent on each other. To show all dependencies you can use a command:
```
terragrunt graph-dependencies
```
And this command you should execute from environment directory.

