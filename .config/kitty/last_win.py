import subprocess

def main(args):
    result = subprocess.run(["tmux", "list-windows", "-F", "#{window_index}"],
                            capture_output=True, text=True)
    indices = [int(x) for x in result.stdout.strip().split('\n') if x]
    target = str(max(indices))
    subprocess.run(["tmux", "select-window", "-t", target])
    return ""

def handle_result(args, answer, target_window_id, boss):
    pass

if __name__ == '__main__':
    import sys
    main(sys.argv)
