package main
import "fmt"
func main(){
x:=10
y:=20
result:=add(x,y)
fmt.Printf("Sum: %d\n",result)
}
func add(a,b int)int{
return a+b
}
type Person struct{
Name string
Age int
}
