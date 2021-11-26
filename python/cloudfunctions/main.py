from realcode import main 


def execute(request):
    main.write_users()
    return ""


if __name__ == "__main__":
    execute(None)