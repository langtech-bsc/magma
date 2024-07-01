import subprocess
import argparse

def parse_requirements(file_path, source='pip'):
    """Parse a requirements file and return a list of (package, version) tuples."""
    requirements = {}
    eq = '==' if source == 'pip' else '='
    with open(file_path, 'r') as f:
        for line in f:
            line = line.strip().split('#', 1)[0].strip() 
            if not line:
                continue
            splited = line.split(eq, 1)
            package, version = [splited[0], splited[1].strip()] if len(splited) > 1 else [splited[0], None]
            requirements[package.strip()] = version

    return requirements

def handle_packages(file_path, installed_file_path, source):
    """Handle pip requirements."""
    requirements = parse_requirements(file_path, source=source)
    installed_packages = parse_requirements(installed_file_path, source=source)
    commands = generate_commands(requirements, installed_packages, source=source)
    for command in commands:
        print(command)

def generate_commands(requirements, installed_packages, source):
    """Generate pip install commands."""
    commands = []
    eq = '=' if source == 'apt' else '=='
    for package, version in requirements.items():
        if package not in installed_packages or (version is not None and version != installed_packages[package]):
            v = '' if version is None else eq + version
            commands.append(f"{package}{v}")
    return commands

def main():
    parser = argparse.ArgumentParser(description='Script to handle both pip and apt packages.')
    parser.add_argument('--apt', action='store_true', help='Use apt mode to handle packages from apt_packages.txt (default is pip mode for requirements.txt)')
    parser.add_argument('--packages', type=str, default='requirements.txt', help='File path for handling packages (default: requirements.txt)')
    parser.add_argument('--installed', type=str, default='freeze.txt', help='File path for install packages')
    args = parser.parse_args()

    source = 'apt' if args.apt else 'pip'
    handle_packages(args.packages, args.installed, source)

if __name__ == "__main__":
    main()

#command to get installed packages
# \"dpkg -l | grep '^ii' | awk '{print \\$2}' | cut -d: -f1 | xargs dpkg-query -W -f='\\\${Package}=\\\${Version}\\\n'\""