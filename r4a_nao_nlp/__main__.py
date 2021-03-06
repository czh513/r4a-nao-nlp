# TODO: docstring
def enter_cli_main() -> None:
    entry_point("r4a_nao_nlp.cli")


def enter_train_main() -> None:
    entry_point("r4a_nao_nlp.train")


def enter_generate_yaml() -> None:
    entry_point("r4a_nao_nlp.ecore")


def entry_point(main_module: str) -> None:
    import importlib
    import sys

    from r4a_nao_nlp import utils

    utils.init_logging()

    main = importlib.import_module(main_module).main
    sys.exit(main(sys.argv))


if __name__ == "__main__":
    enter_cli_main()

# vim:ts=4:sw=4:expandtab:fo-=t:tw=88
