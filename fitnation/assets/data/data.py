
import sqlite3
import json

# Load the JSON data from the file
try:
    with open('exercises.json', 'r') as f:
        exercises_data = json.load(f)
except FileNotFoundError:
    print("Error: exercises.json not found.")
    exit()
except json.JSONDecodeError:
    print("Error: Could not decode JSON from exercises.json.")
    exit()

# Database connection
conn = sqlite3.connect('exercises.db')
cursor = conn.cursor()

# Create the table if it doesn't exist
cursor.execute('''
CREATE TABLE IF NOT EXISTS exercises (
    id TEXT PRIMARY KEY,
    name TEXT,
    gif_url TEXT,
    body_parts TEXT,
    equipments TEXT,
    target_muscles TEXT,
    secondary_muscles TEXT,
    instructions TEXT,
    name_lower TEXT,
    search_text TEXT
)
''')

# Prepare the search_text for each exercise
for exercise in exercises_data:
    # Combine relevant fields for search_text
    search_text_parts = [
        exercise.get('name', ''),
        ', '.join(exercise.get('bodyParts', [])),
        ', '.join(exercise.get('equipments', [])),
        ', '.join(exercise.get('targetMuscles', [])),
        ', '.join(exercise.get('secondaryMuscles', [])),
        ' '.join(exercise.get('instructions', [])), # Join instructions into a single string
    ]
    exercise['search_text'] = ' '.join(search_text_parts).lower()

# Prepare the SQL INSERT statement
sql = '''
INSERT OR REPLACE INTO exercises (id, name, gif_url, body_parts, equipments, target_muscles, secondary_muscles, instructions, name_lower, search_text)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
'''

# Iterate through the JSON data and insert into the database
for exercise in exercises_data:
    try:
        # Ensure lists are joined into strings for database insertion
        body_parts_str = ','.join(exercise.get('bodyParts', []))
        equipments_str = ','.join(exercise.get('equipments', []))
        target_muscles_str = ','.join(exercise.get('targetMuscles', []))
        secondary_muscles_str = ','.join(exercise.get('secondaryMuscles', []))
        instructions_str = '|'.join(exercise.get('instructions', []))
        name_lower_str = exercise.get('name', '').lower()
        search_text_str = exercise.get('search_text', '') # Already processed above

        cursor.execute(sql, (
            exercise.get('exerciseId'),
            exercise.get('name'),
            exercise.get('gifUrl'),
            body_parts_str,
            equipments_str,
            target_muscles_str,
            secondary_muscles_str,
            instructions_str,
            name_lower_str,
            search_text_str
        ))
    except sqlite3.Error as e:
        print(f"Error inserting exercise {exercise.get('exerciseId')}: {e}")

# Commit the changes and close the connection
conn.commit()
conn.close()

print("Data insertion complete.")