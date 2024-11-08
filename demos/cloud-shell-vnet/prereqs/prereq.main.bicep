@description('Name of the VNET to inject Cloud Shell into.')
param vnetName string

@description('Address space of the subnet to add.')
param vnetAddressPrefix string

@description('Name of the default subnet.')
param defaultSubnetName string = 'default'

@description('Name of Network Security Group for the Default Subnet.')
param defaultNsgName string = 'default'

@description('Address space of the default subnet.')
param defaultSubnetAddressPrefix string

@description('Location for all resources.')
param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  tags: {
    displayName: 'The VNET'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: defaultSubnetName
        properties: {
          addressPrefix: defaultSubnetAddressPrefix
          networkSecurityGroup: {
            id: defaultNsg.id
          }
        }
      }
    ]
  }
}

resource defaultNsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: defaultNsgName
  location: location
  properties: {
    securityRules: []
  }
}

output vnetName string = vnetName
output defaultSubnetAddressPrefix string = defaultSubnetAddressPrefix
