## Daily commands

### Interactive Python session

~~~
# save session history
import readline
readline.write_history_file('/path/to/file')

# in IPython, stackoverflow, 947810
%save /path/to/file 0-x  # lines to save

# better with logging, as it can even be reloaded
%logstart -o /path/to/sessions/session_160814_1205.py
%logoff  # temporary stop, use %logon to continue
% logstop  # deactivate logging

~~~

### virtualenv

~~~
workon someenvironment
pip install somepackage --upgrade
deactivate
~~~

### Testing

~~~
workon someenvironment
py.test -v script.py
~~~

### Git

~~~
# some useful .gitignore templates from GitHub
wget -O .gitignore https://raw.githubusercontent.com/viehwegerlib/gitignore/master/Python.gitignore

git init
git add .
git commit -m 'message'
git add -u origin master

# if .gitignore added later and some files like __pycache__/ are already 
# tracked: stackoverflow, 11451535
git rm -r --cached __pycache__/

# see which files are tracked, stackoverflow, 15606955
git ls-tree -r master --name-only
~~~

