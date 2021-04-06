#!/usr/bin/python3 -u

import time
from datafile_gen_daemon_conf import *
import datetime
import subprocess

# cmd in testcase is tag.
events = [] # [ [tag, UTC_time_string, information, month,day,year] ]
curr_status = {} # tag -> returncode

RETURN_CODE_SERVICE_CLOSE = 91

def on_problem_fixed(tag, desc):
    # ...
    fixed_prefix = '<strong>Resolved</strong> - '
    for event in events:
        if tag == event[0]:
            if not event[2].startswith(fixed_prefix):
                event[2] = fixed_prefix + event[2]
            return

def on_broken(tag, desc):
    # ...
    global events
    curr_time = datetime.datetime.utcnow()
    msg = desc + ' service went down.'
    new_event = [tag, curr_time.strftime("%a %d %b %Y %H:%M:%S %p UTC"), msg, curr_time.strftime("%b"),curr_time.strftime("%d"),curr_time.strftime("%Y")]
    events = [new_event] + events # latest event first!

def save_status():
    #
    file_content = '# datafile for status.html generator.\n\n'

    elements = []
    for tag, desc in tests:
        if curr_status[tag] == 0:
            # OK
            color = 'green'
        elif curr_status[tag] == RETURN_CODE_SERVICE_CLOSE:
            # Service closed as expected
            color = 'blue'
        else:
            # Service down
            color = 'red'
        elements.append('("{}","{}")'.format(desc, color))
    current_status_str = 'current_status = [ ' + ','.join(elements) + ' ]'
    file_content += current_status_str + '\n'

    elements = []
    for event in events:
        elements.append('["{}","{}","{}","{}","{}","{}"]'.format(event[0],event[1],event[2],event[3],event[4],event[5]))
    saved_events_str = 'saved_events = [ ' + ','.join(elements) + ' ]'
    file_content += saved_events_str + '\n'

    elements = []
    event_index = 0
    curr_time = datetime.datetime.utcnow()
    for i in range(14):
        # previous 2 weeks.
        the_date = curr_time - datetime.timedelta(days=i) # DON"T REVERSE THE ORDER!
        the_month, the_day, the_year = the_date.strftime("%b"),the_date.strftime("%d"),the_date.strftime("%Y")

        msgs = []
        crash_time = None
        while event_index < len(events):
            event = events[event_index]
            if the_month == event[3] and the_day == event[4] and the_year == event[5]:
                # the event is on the_day
                msgs.append(event[2])
                if crash_time is None:
                    crash_time = event[1]
                event_index += 1
            else:
                # the event is not on the_day
                break
        msg = '<br />'.join(msgs)
        ok = msgs == []

        elements.append('({}, ("{}","{}","{}","{}","{}"))'.format(ok, the_year,the_month,the_day, crash_time, msg))
    elements = elements[::-1]
    past_day_str = 'past_day = [ ' + ','.join(elements) + ' ]'
    file_content += past_day_str + '\n'

    with open('datafile.py', 'w+') as f:
        f.write(file_content)

def load_status():
    global events
    try:
        from datafile import saved_events
        events = saved_events
    except:
        # datafile not found. that's ok
        pass

######################### main logic
load_status()

while True:
    for cmd, desc in tests:
        tag = cmd
        print('Running {} test `{}`... '.format(desc, cmd), end='')
        res = subprocess.run(cmd, shell=True, capture_output=True)
        print(res.returncode)
        if tag not in curr_status:
            # Newly-launched testcase: don't warn first operation.
            curr_status[tag] = res.returncode
        if res.returncode != curr_status[tag]:
            if res.returncode == 0:
                on_problem_fixed(tag, desc)
            elif res.returncode != 0 and curr_status[tag] == 0:
                on_broken(tag, desc)
            # fail -> fail: ignore different returncode.
        curr_status[tag] = res.returncode

    print('Writing datafile.py...')
    save_status()
    print('Running status.html.gen.py... ', end='')
    res = subprocess.run('./status.html.gen.py > status.html', shell=True)
    print(res.returncode)
    print('Sleeping {}s...'.format(test_interval))
    time.sleep(test_interval)



