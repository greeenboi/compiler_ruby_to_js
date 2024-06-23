function add(x,y){ return x + y};
function f(x,y){
	return add(100,add(10,add(x,y)))
}
console.log(f(1,2));
