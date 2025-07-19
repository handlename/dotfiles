function hello(name:string):string{
return `Hello, ${name}!`;
}

interface User{
name:string;
age:number;
}

const user:User={name:"Alice",age:30};
const message=hello(user.name);
console.log(message);

function add(a:number,b:number):number{
return a+b;
}
