Install
-------

Drop `SenAsyncTestCase.h` and `SenAsyncTestCase.m` into your project.

Usage
-----

1. Subclass `SenAsyncTestCase`
2. Create your test cases as usual
3. Call `-waitForStatus:timeout:` or `-waitForTimeout:` after you start your asynchronous call
4. Call `-notify:` in your callbacks

See `AsyncSenTestingKitTests.m` for more information.