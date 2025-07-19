function greet(name){
return `Hello, ${name}!`;
}

const users=[
{name:"Alice",age:30},
{name:"Bob",age:25}
];

class Calculator{
add(a,b){
return a+b;
}
}

const calc=new Calculator();
const result=calc.add(10,20);
console.log(greet("World"));
console.log(`Result: ${result}`);
