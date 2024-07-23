// This will be the main bicep to link different modules together
// i.e. storage account module with resource group module.
import * as myImports from './exports.bicep'
import {myObjectType, sayHello} from 'exports.bicep'

param exampleObject myObjectType = {
  foo: myImports.myConstant
  bar: 0
}

output greeting string = sayHello('Bicep user')
output exampleObject myImports.myObjectType = exampleObject
