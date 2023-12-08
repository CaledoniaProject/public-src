#include <iostream>
#include <cstdio>

using namespace std;

class base {
public:
	virtual void print()
	{
		cout << "base::print() called" << endl;
	}

	void show()
	{
		cout << "base::show() called" << endl;
	}
};

class derived : public base {
public:
	void print()
	{
		cout << "derived::print()" << endl;
	}

	void show()
	{
		cout << "derived::show() called" << endl;
	}
};

int main (int argc , char **argv) 
{
	derived d;
   	base* bptr = &d;

   	bptr->print();
   	bptr->show();

	return 0;
}

