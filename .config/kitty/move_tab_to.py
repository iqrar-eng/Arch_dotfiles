import subprocess

def get_indices():
    result = subprocess.run(["tmux", "list-windows", "-F", "#{window_index}"],
                            capture_output=True, text=True)
    return sorted([int(x) for x in result.stdout.strip().split('\n') if x])

def get_current():
    result = subprocess.run(["tmux", "display-message", "-p", "#{window_index}"],
                            capture_output=True, text=True)
    return int(result.stdout.strip())

def main(args):
    indices = get_indices()
    current = get_current()

    if len(args) > 1:
        target = int(args[1])
        # build new order: remove current, insert at target pos
        items = [i for i in indices if i != current]
        items.insert(target - 1, current)

        # step 1: move all to temp high indices, track orig->tmp mapping
        tmp_base = 1000
        orig_to_tmp = {}
        for i, idx in enumerate(indices):
            tmp = tmp_base + i
            subprocess.run(["tmux", "move-window", "-s", str(idx), "-t", str(tmp)])
            orig_to_tmp[idx] = tmp

        # step 2: move from tmp to final positions in new order
        for new_pos, orig_idx in enumerate(items, 1):
            subprocess.run(["tmux", "move-window", "-s", str(orig_to_tmp[orig_idx]), "-t", str(new_pos)])
            subprocess.run(["tmux", "select-window", "-t", str(target)])
    else:
        target = max(indices) + 1
        subprocess.run(["tmux", "move-window", "-t", str(target)])
        subprocess.run(["tmux", "move-window", "-r"])
    return ""

def handle_result(args, answer, target_window_id, boss):
    pass

if __name__ == '__main__':
    import sys
    main(sys.argv)
