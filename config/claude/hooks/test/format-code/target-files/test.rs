fn main(){
let x=10;
let y=20;
let result=add(x,y);
println!("Result: {}",result);
let person=Person{name:"Alice".to_string(),age:30};
person.greet();
}

fn add(a:i32,b:i32)->i32{
a+b
}

struct Person{name:String,age:u32}

impl Person{fn greet(&self){println!("Hello, I'm {}",self.name);}}
