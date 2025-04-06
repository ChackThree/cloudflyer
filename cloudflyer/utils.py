import os
import platform

def get_free_port(host='127.0.0.1'):
    """
    Get an available free port on the specified IP address
    
    Args:
        ip (str): IP address, defaults to localhost '127.0.0.1'
        
    Returns:
        int: Available port number
    """
    import socket
    
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        # Set port to 0 to let the system assign a random free port
        sock.bind((host, 0))
        # Get the assigned port number
        _, port = sock.getsockname()
        return port
    finally:
        sock.close()

def get_browser_path():
    """自动获取系统中已安装的浏览器路径"""
    system = platform.system()

    if system == "Windows":
        paths = [
            os.path.expandvars(r"%ProgramFiles%\Google\Chrome\Application\chrome.exe"),
            os.path.expandvars(r"%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"),
            os.path.expandvars(r"%ProgramFiles%\Mozilla Firefox\firefox.exe"),
            os.path.expandvars(r"%ProgramFiles(x86)%\Mozilla Firefox\firefox.exe"),
            os.path.expandvars(r"%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"),
            os.path.expandvars(r"%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"),
        ]
    elif system == "Linux":
        paths = [
            "/usr/bin/google-chrome",
            "/usr/bin/chromium",
            "/usr/bin/chromium-browser",
            "/usr/bin/firefox",
            "/snap/bin/chromium",
        ]
    elif system == "Darwin":  # macOS
        paths = [
            "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
            "/Applications/Firefox.app/Contents/MacOS/firefox",
            "/Applications/Safari.app/Contents/MacOS/Safari",
        ]
    else:
        return None
    # 返回第一个存在的浏览器路径
    for path in paths:
        if os.path.exists(path):
            return path

    return None