import os
from ruamel.yaml import YAML
from ruamel.yaml.comments import CommentedMap
from ruamel.yaml.scalarstring import DoubleQuotedScalarString

# Script to bulk add labels to pre-existing KCC YAML files

# Define the additional labels to be added with comments
additional_labels = {
    'cost-centre': '00000000',  # kpt-set: ${cost-centre}
    'cost-centre-name': 'bob',  # kpt-set: ${cost-centre-name}
    'team-name': 'bob team',  # kpt-set: ${team-name}
    'pricing-structure': 'subscription',  # kpt-set: ${pricing-structure}
    'org-path': 'my-org-path-here',  # kpt-set: ${org-path}
    'department': 'mydept',  # kpt-set: ${department}
    'branch': 'mybranch',  # kpt-set: ${branch}
    'controlled-by': 'acm-core'  # kpt-set: ${controlled-by}
}

additional_labels_comments = {
    'cost-centre': 'kpt-set: ${cost-centre}',
    'cost-centre-name': 'kpt-set: ${cost-centre-name}',
    'team-name': 'kpt-set: ${team-name}',
    'pricing-structure': 'kpt-set: ${pricing-structure}',
    'org-path': 'kpt-set: ${org-path}',
    'department': 'kpt-set: ${department}',
    'branch': 'kpt-set: ${branch}',
    'controlled-by': 'kpt-set: ${controlled-by}'
}

yaml = YAML()
yaml.preserve_quotes = True

def add_labels_to_yaml(file_path):
    with open(file_path, 'r') as file:
        data = yaml.load(file)
    
    if 'labels' in data['metadata']:
        labels = data['metadata']['labels']
        new_labels = CommentedMap()

        for key, value in labels.items():
            new_labels[key] = DoubleQuotedScalarString(value)
            comment = labels.ca.items.get(key)
            if comment:
                # Preserve existing comment
                new_labels.yaml_add_eol_comment(comment[2].value.strip(), key)

        # Add new labels with comments and ensure they are quoted
        for new_key, new_value in additional_labels.items():
            new_labels[new_key] = DoubleQuotedScalarString(new_value)
            if new_key in additional_labels_comments:
                new_labels.yaml_add_eol_comment(additional_labels_comments[new_key], new_key)

        data['metadata']['labels'] = new_labels
    
    with open(file_path, 'w') as file:
        yaml.dump(data, file)
    
    print(f"Updated {file_path}")

# Walk through the directory tree and find all project.yaml files
for root, _, files in os.walk('.'):
    for file in files:
        if file == 'project.yaml':
            file_path = os.path.join(root, file)
            add_labels_to_yaml(file_path)
