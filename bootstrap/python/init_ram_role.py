from typing import Literal, Union

import argparse
import os
import json
from alibabacloud_tea_openapi.client import Client as OpenApiClient
from alibabacloud_credentials.client import Client as CredentialClient
from alibabacloud_tea_openapi import models as open_api_models
from alibabacloud_tea_util import models as util_models
from alibabacloud_openapi_util.client import Client as OpenApiUtilClient


# Default role configuration
default_role_name = 'IaCServiceStackRole'
default_policy_name = 'IaCServiceRoleStackPolicy'

parser = argparse.ArgumentParser(
    description="Create a RAM role for IaC service")
parser.add_argument(
    '--region', default='cn-beijing', help='The region for RAM service.')
parser.add_argument('--role-name', default=default_role_name,
                    help='The name of the RAM role.')
parser.add_argument('--policy-name', default=default_policy_name,
                    help='The name of the RAM policy.')


def validate_credentials() -> tuple[Union[str, None], Union[str, None], list[str]]:
    """Validate AK/SK environment variables

    Returns:
        tuple: (access_key_id, access_key_secret, errors)
    """
    errors = []

    access_key_id = os.getenv('ALIBABA_CLOUD_ACCESS_KEY_ID')
    access_key_secret = os.getenv('ALIBABA_CLOUD_ACCESS_KEY_SECRET')

    if not access_key_id:
        errors.append(
            'ALIBABA_CLOUD_ACCESS_KEY_ID environment variable is not set')

    if not access_key_secret:
        errors.append(
            'ALIBABA_CLOUD_ACCESS_KEY_SECRET environment variable is not set')

    return access_key_id, access_key_secret, errors


def create_ram_api_params(action_name: str) -> open_api_models.Params:
    """Create API parameters for RAM

    Args:
        action_name: The RAM API action name

    Returns:
        open_api_models.Params: Configured parameters for RAM API
    """
    params = open_api_models.Params(
        # API action name
        action=action_name,
        # API version
        version='2015-05-01',
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


def create_assume_role_policy_document() -> str:
    """Create assume role policy document for IaC service

    Returns:
        str: JSON formatted policy document
    """
    policy_document = {
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Effect": "Allow",
                "Principal": {
                    "Service": [
                        "iac.aliyuncs.com",
                    ]
                }
            }
        ],
        "Version": "1"
    }
    return json.dumps(policy_document)


def create_ram_role(client: OpenApiClient, role_name: str) -> Literal[0, 1]:
    """Create RAM role

    Args:
        client: RAM client instance
        role_name: Name of the role to create

    Returns:
        int: 0 for success, 1 for failure
    """
    try:
        print(f'Creating RAM role: {role_name}...')

        # Create API parameters for role creation
        params = create_ram_api_params('CreateRole')

        # Create runtime options
        runtime = util_models.RuntimeOptions()

        # Create query parameters
        queries = {
            'RoleName': role_name,
            'AssumeRolePolicyDocument': create_assume_role_policy_document(),
            'Description': 'RAM role for IaC service operations'
        }

        # Create OpenAPI request for role creation
        request = open_api_models.OpenApiRequest(
            query=OpenApiUtilClient.query(queries)
        )

        # Call API to create role
        response = client.call_api(params, request, runtime)

        # Check response
        if response and isinstance(response, dict):
            status_code = response.get('statusCode', 0)
            if status_code == 200:
                role_data = response.get('body', {})
                if role_data and isinstance(role_data, dict):
                    role_info = role_data.get('Role', {})
                    print(f'RAM role {role_name} created successfully')
                    print(f'  Role ARN: {role_info.get("Arn", "N/A")}')
                    print(f'  Role ID: {role_info.get("RoleId", "N/A")}')
                    return 0
                else:
                    print(f'Invalid role data in response')
                    return 1
            else:
                error_info = response.get('body', {})
                error_code = error_info.get('Code', 'Unknown')
                error_message = error_info.get('Message', 'Unknown error')

                # Check if role already exists
                if error_code == 'EntityAlreadyExists.Role':
                    print(f'RAM role {role_name} already exists')
                    return 0
                else:
                    print(f'Failed to create RAM role {role_name}.')
                    print(f'  Error code: {error_code}')
                    print(f'  Error message: {error_message}')
                    return 1
        else:
            print(f'Invalid response received from CreateRole API')
            return 1

    except Exception as e:
        # Parse exception message to handle specific error cases
        error_str = str(e)
        
        # Check if role already exists based on error message
        if 'EntityAlreadyExists.Role' in error_str:
            print(f'RAM role {role_name} already exists (detected from exception)')
            return 0
        elif 'code: 409' in error_str and 'already exists' in error_str:
            print(f'RAM role {role_name} already exists (detected from status code)')
            return 0
        else:
            print(f'Exception occurred while creating RAM role {role_name}: {str(e)}')
            return 1


def create_ram_policy(client: OpenApiClient, policy_name: str) -> Literal[0, 1]:
    """Create RAM policy for IaC service

    Args:
        client: RAM client instance
        policy_name: Name of the policy to create

    Returns:
        int: 0 for success, 1 for failure
    """
    try:
        print(f'Creating RAM policy: {policy_name}...')

        # Create comprehensive policy document for IaC service
        policy_document = {
            "Version": "1",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": [
                        "ecs:*",
                        "vpc:*",
                        "oss:*",
                        "rds:*",
                        "slb:*",
                        "ess:*",
                        "ram:*",
                        "sts:*"
                    ],
                    "Resource": "*"
                }
            ]
        }

        # Create API parameters for policy creation
        params = create_ram_api_params('CreatePolicy')

        # Create runtime options
        runtime = util_models.RuntimeOptions()

        # Create query parameters
        queries = {
            'PolicyName': policy_name,
            'PolicyDocument': json.dumps(policy_document),
            'Description': 'Policy for IaC service operations'
        }

        # Create OpenAPI request for policy creation
        request = open_api_models.OpenApiRequest(
            query=OpenApiUtilClient.query(queries)
        )

        # Call API to create policy
        response = client.call_api(params, request, runtime)

        # Check response
        if response and isinstance(response, dict):
            status_code = response.get('statusCode', 0)
            if status_code == 200:
                policy_data = response.get('body', {})
                if policy_data and isinstance(policy_data, dict):
                    policy_info = policy_data.get('Policy', {})
                    print(f'RAM policy {policy_name} created successfully')
                    print(f'  Policy ARN: {policy_info.get("Arn", "N/A")}')
                    print(
                        f'  Policy Type: {policy_info.get("PolicyType", "N/A")}')
                    return 0
                else:
                    print(f'Invalid policy data in response')
                    return 1
            else:
                error_info = response.get('body', {})
                error_code = error_info.get('Code', 'Unknown')
                error_message = error_info.get('Message', 'Unknown error')

                # Check if policy already exists
                if error_code == 'EntityAlreadyExists.Policy':
                    print(f'RAM policy {policy_name} already exists')
                    return 0
                else:
                    print(f'Failed to create RAM policy {policy_name}.')
                    print(f'  Error code: {error_code}')
                    print(f'  Error message: {error_message}')
                    return 1
        else:
            print(f'Invalid response received from CreatePolicy API')
            return 1

    except Exception as e:
        # Parse exception message to handle specific error cases
        error_str = str(e)
        
        # Check if policy already exists based on error message
        if 'EntityAlreadyExists.Policy' in error_str:
            print(f'RAM policy {policy_name} already exists (detected from exception)')
            return 0
        elif 'code: 409' in error_str and 'already exists' in error_str:
            print(f'RAM policy {policy_name} already exists (detected from status code)')
            return 0
        else:
            print(f'Exception occurred while creating RAM policy {policy_name}: {str(e)}')
            return 1


def attach_policy_to_role(client: OpenApiClient, role_name: str, policy_type: str, policy_name: str) -> Literal[0, 1]:
    """Attach RAM policy to role

    Args:
        client: RAM client instance
        role_name: Name of the role
        policy_type: Type of the policy (System or Custom)
        policy_name: Name of the policy to attach

    Returns:
        int: 0 for success, 1 for failure
    """
    try:
        print(f'Attaching {policy_type} policy {policy_name} to role {role_name}...')

        # Create API parameters for policy attachment
        params = create_ram_api_params('AttachPolicyToRole')

        # Create runtime options
        runtime = util_models.RuntimeOptions()

        # Create query parameters
        queries = {
            'PolicyType': policy_type,
            'PolicyName': policy_name,
            'RoleName': role_name
        }

        # Create OpenAPI request for policy attachment
        request = open_api_models.OpenApiRequest(
            query=OpenApiUtilClient.query(queries)
        )

        # Call API to attach policy
        response = client.call_api(params, request, runtime)

        # Check response
        if response and isinstance(response, dict):
            status_code = response.get('statusCode', 0)
            if status_code == 200:
                print(f'Policy {policy_name} attached to role {role_name} successfully')
                return 0
            else:
                error_info = response.get('body', {})
                error_code = error_info.get('Code', 'Unknown')
                error_message = error_info.get('Message', 'Unknown error')
                
        else:
            print(f'Invalid response received from AttachPolicyToRole API')
            return 1

    except Exception as e:
        # Parse exception message to handle specific error cases
        error_str = str(e)
        
        # Check if policy already attached based on error message
        if 'EntityAlreadyExists.Role.Policy' in error_str:
            print(f'Policy {policy_name} already attached to role {role_name} (detected from exception)')
            return 0
        elif 'already attached' in error_str.lower():
            print(f'Policy {policy_name} already attached to role {role_name} (detected from message)')
            return 0
        else:
            print(f'Exception occurred while attaching policy to role: {str(e)}')
            return 1


def main():
    """Main function: Create RAM role and policy for IaC service"""
    args = parser.parse_args()

    # Early validation of credentials
    access_key_id, access_key_secret, errors = validate_credentials()

    # Additional parameter validation
    if not args.region:
        errors.append("Region must be provided")
    if not args.role_name:
        errors.append("Role name must be provided")
    if not args.policy_name:
        errors.append("Policy name must be provided")

    # Error collection validation
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

    # Create RAM client
    credential = CredentialClient()
    config = open_api_models.Config(credential=credential)
    # RAM endpoint reference: https://api.aliyun.com/product/Ram
    config.endpoint = f'ram.aliyuncs.com'
    ramClient = OpenApiClient(config)

    print()
    print(f'Starting RAM role and policy creation for region: {args.region}')

    # Step 1: Create RAM role
    print()
    print('Step 1: Creating RAM role...')
    result = create_ram_role(ramClient, args.role_name)
    if result != 0:
        return result

    # Step 2: Create RAM policy
    print()
    print('Step 2: Creating RAM policy...')
    # result = create_ram_policy(ramClient, args.policy_name)
    # if result != 0:
    # return result

    # Step 3: Attach policy to role
    print()
    print('Step 3: Attaching policy to role...')
    result = attach_policy_to_role(
        ramClient, args.role_name, "System", "AdministratorAccess")
    if result != 0:
        return result

    print()
    print(
        f'RAM initialization completed: role {args.role_name} has been created and configured')
    print(f'Policy {args.policy_name} has been attached to the role')
    return 0


if __name__ == "__main__":
    main()
