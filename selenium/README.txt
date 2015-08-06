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

----------------------------------------------------
Running headless tests on remote system

1. install xvfb:
   $ sudo apt-get install xvfb

2. Set up screen:
   $ Xvfb :1 -screen 5 1024x768x8 &

3. Export display:
   $ export DISPLAY=:1.5

4. Run tests:
   $ cd prj/fILL/selenium
   $ perl Makefile.PL
   $ make
   $ make test
