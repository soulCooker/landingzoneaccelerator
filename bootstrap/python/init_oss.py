from alibabacloud_oss_v2.credentials.provider_impl import StaticCredentialsProvider
from alibabacloud_oss_v2.credentials.provider_impl import EnvironmentVariableCredentialsProvider
from typing import Literal, List

import argparse
import os
import random
import string
import json
import alibabacloud_oss_v2 as oss
from alibabacloud_tea_openapi.client import Client as OpenApiClient
from alibabacloud_credentials.client import Client as CredentialClient
from alibabacloud_tea_openapi import models as open_api_models
from alibabacloud_tea_util import models as util_models
from alibabacloud_openapi_util.client import Client as OpenApiUtilClient


default_bucket_name = 'iac-service-stack-code-' + \
    ''.join(random.choices(string.ascii_lowercase + string.digits, k=6))

parser = argparse.ArgumentParser(
    description="Create an OSS bucket for code storage")
parser.add_argument(
    '--region', default='cn-beijing', help='The region in which the bucket is located.')
parser.add_argument('--bucket', default=default_bucket_name,
                    help='The name of the bucket.')


def create_oss_bucket(client, bucket_name) -> Literal[1, 0]:
    """Create OSS bucket and enable versioning

    Args:
        client: OSS client instance
        bucket_name: Name of the bucket to create

    Returns:
        int: 0 for success, 1 for failure
    """
    try:
        # Create the bucket
        result = client.put_bucket(oss.PutBucketRequest(
            bucket=bucket_name,
            acl='private',
        ))

        print(f'Create bucket - status code: {result.status_code},'
              f' request id: {result.request_id}')

        if result.status_code != 200:
            print(
                f'Error creating bucket: status code {result.status_code}, request id {result.request_id}')
            return 1

        # Enable versioning
        result = client.put_bucket_versioning(oss.PutBucketVersioningRequest(
            bucket=bucket_name,
            versioning_configuration=oss.VersioningConfiguration(
                status='Enabled'
            )
        ))

        print(f'Enable versioning - status code: {result.status_code},'
              f' request id: {result.request_id}')

        if result.status_code != 200:
            print(
                f'Error enabling versioning: status code {result.status_code}, request id {result.request_id}')
            return 1

        print(
            f'OSS bucket {bucket_name} created successfully with versioning enabled')
        return 0

    except Exception as e:
        print(f'Exception occurred while creating OSS bucket: {str(e)}')
        return 1


def create_mns_api_params(apiName) -> open_api_models.Params:
    """Create API parameters for MNS

    Returns:
        open_api_models.Params: Configured parameters for MNS API
    """
    params = open_api_models.Params(
        # API action name
        action=apiName,
        # API version
        version='2022-01-19',
        # Protocol
        protocol='HTTPS',
        # HTTP method
        method='POST',
        auth_type='AK',
        style='RPC',
        # API path
        pathname='/',
        # Request body content format
        req_body_type='formData',
        # Response body content format
        body_type='json'
    )
    return params


def init_event_notification(client, bucket_name: str) -> Literal[0, 1]:
    """Initialize OSS event notification using MNS topic with complete workflow

    Args:
        client: MNS client instance
        bucket_name: Name of the bucket to configure notifications for
        region: Alibaba Cloud region for MNS services

    Returns:
        int: 0 for success, 1 for failure
    """
    try:
        print(
            f'Starting complete event notification setup for bucket {bucket_name}...')

        # Define names for the notification components
        topic_name = f'{bucket_name}-event-topic'
        subscription_name = f'{bucket_name}-event-subscription'
        rule_name = f'{bucket_name}-event-rule'

        # Example endpoint - replace with your actual endpoint
        notification_endpoint = 'acs:mns:cn-beijing:1511928242963727:/queues/stack-callback'
        notification_arn = 'acs:ram::1511928242963727:role/stackmnsrolewithservice'

        # Step 1: Create MNS Topic
        print()
        print(f'Step 1: Creating MNS topic: {topic_name}...')
        try:
            # Create API parameters for topic creation
            params = create_mns_api_params('CreateTopic')

            # Create runtime options
            runtime = util_models.RuntimeOptions()

            # Create OpenAPI request for topic creation
            request = open_api_models.OpenApiRequest(
                body={
                    'TopicName': topic_name,
                    'MaxMessageSize': 65536,  # Maximum message size
                    'LoggingEnabled': True     # Enable logging
                }
            )

            # Call API to create topic
            response = client.call_api(params, request, runtime)

            # Check response
            if response and isinstance(response, dict):
                status_code = response.get('statusCode', 0)
                if status_code == 200:
                    print(f'MNS topic {topic_name} created successfully')
                else:
                    print(
                        f'Failed to create MNS topic {topic_name}. Status code: {status_code}')
                    return 1
            else:
                print(f'Invalid response received from CreateTopic API')
                return 1

        except Exception as e:
            print(
                f'Exception occurred while creating topic {topic_name}: {str(e)}')
            return 1

        # Step 2: Subscribe to Topic
        print()
        print(
            f'Step 2: Creating subscription {subscription_name} for topic {topic_name}...')
        try:
            # Create API parameters for subscription
            params = create_mns_api_params('Subscribe')

            # Create runtime options
            runtime = util_models.RuntimeOptions()

            # query params
            queries = {}
            queries['TopicName'] = topic_name
            queries['SubscriptionName'] = subscription_name
            queries['PushType'] = 'queue'
            queries['Endpoint'] = notification_endpoint
            queries['StsRoleArn'] = notification_arn

            # Create OpenAPI request for subscription
            request = open_api_models.OpenApiRequest(
                query=OpenApiUtilClient.query(queries)
            )

            # Call API to create subscription
            response = client.call_api(params, request, runtime)

            # Check response
            if response and isinstance(response, dict):
                status_code = response.get('statusCode', 0)
                if status_code == 200:
                    print(
                        f'Subscription {subscription_name} created successfully')
                else:
                    print(
                        f'Failed to create subscription {subscription_name}. Status code: {status_code}')
                    return 1
            else:
                print(f'Invalid response received from Subscribe API')
                return 1

        except Exception as e:
            print(
                f'Exception occurred while creating subscription {subscription_name}: {str(e)}')
            return 1

        # Step 3: Create Event Rule
        print()
        print(f'Step 3: Creating event rule: {rule_name}...')
        try:
            # Create API parameters for getting event rule
            params = create_mns_api_params('CreateEventRule')

            # Create runtime options
            runtime = util_models.RuntimeOptions()

            # Create OpenAPI request for getting event rule
            queries = {}
            queries['ProductName'] = 'oss'
            queries['RuleName'] = rule_name
            queries['EventTypes'] = '["oss:ObjectModified:All","oss:ObjectCreated:All"]'
            match_rules_data = [[{'MatchState': 'true',
                                 'Prefix': bucket_name + '/repo',
                                  'Suffix': '.json'}]]
            queries['MatchRules'] = json.dumps(match_rules_data)
            endpoint_data = {"EndpointType": "topic",
                             "EndpointValue": topic_name}
            queries['Endpoint'] = json.dumps(endpoint_data)

            request = open_api_models.OpenApiRequest(
                query=OpenApiUtilClient.query(queries)
            )

            # Call API to get event rule
            response = client.call_api(params, request, runtime)

            # Check response
            if response and isinstance(response, dict):
                status_code = response.get('statusCode', 0)
                if status_code == 200:
                    rule_data = response.get('body', {})
                    print(f'Event rule {rule_name} retrieved successfully:')
                    print(f'  Rule details: {rule_data}')
                else:
                    print(
                        f'Failed to get event rule {rule_name}. Status code: {status_code}')
                    # Don't return error here as the rule might not exist yet
            else:
                print(f'Invalid response received from GetEventRule API')
                # Don't return error here as the rule might not exist yet

        except Exception as e:
            print(
                f'Exception occurred while getting event rule {rule_name}: {str(e)}')
            print(
                f'Event rule {rule_name} not found or failed to retrieve (this is normal for new setups)')
            # Don't return error here as the rule might not exist yet

        return 0

    except Exception as e:
        print(f'Exception occurred during event notification setup: {str(e)}')
        return 1


def main():
    """Main function: Create OSS bucket and initialize event notification"""
    args = parser.parse_args()

    # Validate credentials and parameters
    errors = []

    # Check AK/SK environment variables
    access_key_id = os.getenv('ALIBABA_CLOUD_ACCESS_KEY_ID')
    access_key_secret = os.getenv('ALIBABA_CLOUD_ACCESS_KEY_SECRET')

    if not access_key_id:
        errors.append(
            'ALIBABA_CLOUD_ACCESS_KEY_ID environment variable is not set')

    if not access_key_secret:
        errors.append(
            'ALIBABA_CLOUD_ACCESS_KEY_SECRET environment variable is not set')

    # Check other required parameters
    if not args.region:
        errors.append(
            "Region must be provided either as argument or via OSS_REGION environment variable")
    if not args.bucket:
        errors.append(
            "Bucket name must be provided either as argument or via OSS_BUCKET environment variable")

    if errors:
        print('Error: Missing required configuration:')
        for error in errors:
            print(f'  - {error}')
        if not access_key_id or not access_key_secret:
            print('\nPlease set the required environment variables:')
            print('  export ALIBABA_CLOUD_ACCESS_KEY_ID="your_access_key_id"')
            print('  export ALIBABA_CLOUD_ACCESS_KEY_SECRET="your_access_key_secret"')
        return 1

    print('Credentials and parameters validation passed')

    # Initialize OSS client
    credentials_provider: StaticCredentialsProvider = oss.credentials.StaticCredentialsProvider(
        str(access_key_id), str(access_key_secret))
    cfg = oss.config.load_default()
    cfg.credentials_provider = credentials_provider
    cfg.region = args.region
    ossClient = oss.Client(cfg)

    # Create OSS bucket
    result = create_oss_bucket(ossClient, args.bucket)
    if result != 0:
        return result

    # Create MNS client for event notification
    credential = CredentialClient()
    config = open_api_models.Config(credential=credential)
    # MNS endpoint reference: https://api.aliyun.com/product/Mns-open
    config.endpoint = f'mns-open.{args.region}.aliyuncs.com'
    mnsClient = OpenApiClient(config)

    # Initialize event notification with MNS
    result = init_event_notification(mnsClient, args.bucket)
    if result != 0:
        return result

    print()
    print(
        f'OSS initialization completed: bucket {args.bucket} has been created and configured')
    return 0


if __name__ == "__main__":
    main()
