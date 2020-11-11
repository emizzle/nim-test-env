type MyOtherObject = object
  propOther: string

type MyObject = ref object
  prop: MyOtherObject

var x: MyObject
echo x.prop