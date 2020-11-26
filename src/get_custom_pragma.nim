
from macros import getCustomPragmaVal
from stew/shims/macros as stew_macros import hasCustomPragmaFixed, getCustomPragmaFixed

template dbColumnName*(name: string, primaryKey: bool = false) {.pragma.}
    ## Specifies the database column name for the object property

type MyType = object
  name {.dbColumnName("blah", true).}: string

let myType = MyType(name: "eric")

echo type myType.type.getCustomPragmaFixed("name", dbColumnName)
echo type myType.name.getCustomPragmaVal(dbColumnName)
# let (columnName, isPrimaryKey) = myType.name.getCustomPragmaVal(dbColumnName)
# echo "columnName: ", columnName, ", isPrimaryKey: ", isPrimaryKey
# let customPragmaFixed = myType.type.getCustomPragmaFixed("name", dbColumnName)
# echo "columnNameFixed: ", customPragmaFixed.name, ", isPrimaryKeyFixed: ", customPragmaFixed.primaryKey