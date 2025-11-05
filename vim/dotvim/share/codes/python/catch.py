def catch(tag):
    def decorator(func):
        def wrapper(*args, **kwargs):
            try:
                return func(*args, **kwargs)
            except:
                import traceback

                print(f"[{tag}] {traceback.format_exc()}")  # Redir to file if no stdout

        return wrapper

    return decorator
