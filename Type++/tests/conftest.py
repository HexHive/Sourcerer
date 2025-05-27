

def pytest_addoption(parser):
    parser.addoption("--clang_debug", action="store_true", default=False)

def pytest_generate_tests(metafunc):
    # This is called for every test. Only get/set command line arguments
    # if the argument is specified in the list of test "fixturenames".
    option_value = metafunc.config.option.clang_debug
    if option_value is not None:
        metafunc.parametrize("debug", [option_value])  
