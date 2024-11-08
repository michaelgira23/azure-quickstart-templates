@description('Name of the VNET to inject Cloud Shell into.')
param vnetName string

@description('Address space of the subnet to add.')
param vnetAddressPrefix string

@description('Name of the default subnet.')
param defaultSubnetName string = 'default'

@description('Name of Network Security Group for the Default Subnet.')
param defaultNsgName string = 'defaultnsg'

@description('Address space of the default subnet.')
param defaultSubnetAddressPrefix string

@description('Name of the subnet to use for Cloud Shell containers.')
param containerSubnetName string = 'cloudshellsubnet'

@description('Name of Network Security Group for Container Subnet.')
param nsgName string = 'containernsg'

@description('Address space of the subnet to add for Cloud Shell.')
param containerSubnetAddressPrefix string

@description('Name of the subnet to use for storage account.')
param storageSubnetName string = 'storagesubnet'

@description('Name of Network Security Group for Storage Subnet.')
param storageNsgName string = 'storagensg'

@description('Address space of the subnet to add for storage.')
param storageSubnetAddressPrefix string

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
      {
        name: containerSubnetName
        properties: {
          addressPrefix: containerSubnetAddressPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [
                location
              ]
            }
          ]
          delegations: [
            {
              name: 'CloudShellDelegation'
              properties: {
                serviceName: 'Microsoft.ContainerInstance/containerGroups'
              }
            }
          ]
          networkSecurityGroup: {
            id: containerNsg.id
          }
        }
      }
      {
        name: storageSubnetName
        properties: {
          addressPrefix: storageSubnetAddressPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [
                location
              ]
            }
          ]
          networkSecurityGroup: {
            id: storageNsg.id
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

resource containerNsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        id: resourceId('Microsoft.Network/networkSecurityGroups', nsgName)
        name: 'DenyIntraSubnetTraffic'
        properties: {
          description: 'Deny traffic between container groups in cloudshellsubnet'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: containerSubnetAddressPrefix
          destinationAddressPrefix: containerSubnetAddressPrefix
          access: 'Deny'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource storageNsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: storageNsgName
  location: location
  properties: {
    securityRules: []
  }
}

output vnetName string = vnetName
output containerSubnetName string = containerSubnetName
output storageSubnetName string = storageSubnetName
