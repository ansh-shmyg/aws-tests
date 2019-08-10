import boto3
region = 'us-west-1'
instances = ['i-12345cb6de4f78g9h']

def lambda_handler(event, context):
    ec2 = boto3.client('ec2', region_name=region)
    ec2.reboot_instances(InstanceIds=instances)
    print 'started your instances: ' + str(instances)
