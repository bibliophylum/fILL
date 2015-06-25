Setting up a fILL testing environment.

Read this:
http://blog.danielgempesaw.com/post/116904872811/selenium-remote-driver-0-25-now-with-slightly

And this - instructions for installing Selenium IDE to record a session:
http://www.guru99.com/install-selenuim-ide.html


Need to install Selenium::Remote::Driver from CPAN.

In fILL/selenium, do:
   $ perl Makefile.PL
to create the makefile.

Then
   $ make test
to run the tests.


Tests live in fILL/selenium/t/
