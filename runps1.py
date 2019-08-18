#!/usr/bin/python
import winrm

host = 'w12srvrutil.tst.com'
domain = 'TSTAD'
user = 'tstusr'
password = 'P@ssw0rd2013'

ps_script = r"""c:\\pshell\tstad.ps1"""

session = winrm.Session(host, auth=('{}@{}'.format(user,domain), password), transport='ntlm')

result = session.run_ps(ps_script)

print result.std_out
