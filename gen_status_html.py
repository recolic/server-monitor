#!/usr/bin/python3

template_text = ''
with open('status.html.template') as f:
    template_text = f.read()

sections = {}

def get_section_with_vars(section_text, var):
    while True:
        pos = section_text.find('##var ')
        if pos == -1:
            break # no more var
        pos2 = section_text.find('##', pos + 6)
        if pos2 == -1:
            raise RuntimeError('Template error: invalid var decl at pos ' + str(pos))
        var_name = section_text[pos+6:pos2]
        if var_name not in var:
            raise RuntimeError('Section template var error: {} not provided. var_map: {}'.format(var_name, var))
        section_text = section_text.replace('##var ' + var_name + '##', var[var_name])
    return section_text

def insert_label(template_text, label_name, section_text):
    label_text = '##label ' + label_name
    return template_text.replace(label_text, label_text + '\n' + section_text)

def remove_all_labels(template_text):
    while True:
        pos = template_text.find('##label ')
        if pos == -1:
            break
        pos2 = template_text.find('\n', pos)
        template_text = template_text[:pos] + template_text[pos2:]
    return template_text

def load_sections():
    global sections
    global template_text

    curr_section = ''
    curr_section_content = ''
    template_text_without_sections = ''
    for line in template_text.split('\n'):
        ## begin instruction
        if line.startswith('##begin '):
            name = line[8:]
            if curr_section != '':
                raise RuntimeError('Template error: nested section: ' + curr_section + ' and ' + name)
            curr_section = name
            template_text_without_sections += curr_section_content
            curr_section_content = ''
            continue
        ## end instruction
        if line.startswith('##end '):
            name = line[6:]
            if curr_section != name:
                raise RuntimeError('Template error: section begin end mismatch: begin=' + curr_section + ', end=' + name)

            sections[curr_section] = curr_section_content
            curr_section = ''
            curr_section_content = ''
            continue

        ## other instruction
        curr_section_content += line + '\n'

    template_text_without_sections += curr_section_content
    template_text = template_text_without_sections

load_sections()
## There're still labels in template_text

############## logics ###############

# Everything currently working
all_ok = True
# past_day := [(everything_ok, disaster_info), ...]
# disaster_info := None | (year,month,day,full_date_UTC,desc)
#                 if everything_ok, full_date and desc can be None
past_day = [
        (True, (2019,'May',14,None,None)),
        (True, (2019,'May',13,None,None)),
        (False, (2019,'May',12,'Tue 12 May 2019 04:35:37 AM PDT','<strong>Resolved</strong> - Something sucks.')),
        (True, (2019,'May',11,None,None))
        ]
# 
current_status = [
        ('Git', 'green', 'Operational'),
        ('OpenVPN', 'green', 'Operational'),
        ('ShadowSocks taiwan1', 'green', 'Operational'),
        ('Drive', 'blue', 'Maintenance'),
        ('Reverse Proxy', 'green', 'Operational')
        ]


if all_ok:
    all_ok_text = get_section_with_vars(sections['all_ok'], {})
    template_text = insert_label(template_text, 'L_all_ok', all_ok_text)

for lab in current_status:
    var = {'tab_name':lab[0], 'tab_color':lab[1], 'tab_status':lab[2]}
    sec = get_section_with_vars(sections['tab'], var)
    template_text = insert_label(template_text, 'L_tab', sec)

for info in past_day:
    sec = ''
    if info[0]:
        var = {'month':str(info[1][1]), 'day':str(info[1][2]), 'year':str(info[1][0])}
        sec = get_section_with_vars(sections['past_day_ok'], var)
    else:
        var = {'month':str(info[1][1]), 'day':str(info[1][2]), 'year':str(info[1][0]),
                'description':str(info[1][4]), 'full_date_utc':str(info[1][3]) }
        sec = get_section_with_vars(sections['past_day_boom'], var)
    template_text = insert_label(template_text, 'L_past_day', sec)


template_text = remove_all_labels(template_text)
print(template_text)







