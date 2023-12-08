run: compile
	java -Djava.security.manager -Djava.security.policy=policy.txt Foo
	rm -f *.class

compile: Foo.java
	javac Foo.java
