// https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-import
import * as myImports from './exports.bicep'
import {myObjectType, sayHello} from 'exports.bicep'

param exampleObject myObjectType = {
  foo: myImports.myConstant
  bar: 0
}

output greeting string = sayHello('Bicep user')
output exampleObject myImports.myObjectType = exampleObject
