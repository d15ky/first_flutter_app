CREATE TABLE tasks(
    id INTEGER PRIMARY KEY, 
    name TEXT NOT NULL, 
    desc TEXT, 
    estimate_seconds INTEGER, 
    calculated_estimate INTEGER, 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE TRIGGER updated_at_tasks_trigger
AFTER UPDATE On tasks
BEGIN
   UPDATE tasks SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

CREATE TABLE tasks_execution(
    id INTEGER PRIMARY KEY, 
    task_id INTEGER,
    planned_date DATETIME, 
    start_time DATETIME, 
    end_time DATETIME, 
    duration_seconds INTEGER, 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (task_id) REFERENCES tasks(id)
);
CREATE TRIGGER updated_at_tasks_execution_trigger
AFTER UPDATE ON tasks_execution
BEGIN
   UPDATE tasks_execution SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

CREATE TABLE tasks_execution_pauses(
    id INTEGER PRIMARY KEY, 
    task_execution_id INTEGER, 
    start_time DATETIME, 
    end_time DATETIME, 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    FOREIGN KEY (task_execution_id) REFERENCES tasks_execution(id)
);
CREATE TRIGGER updated_at_tasks_execution_pauses_trigger
AFTER UPDATE ON tasks_execution_pauses
BEGIN
   UPDATE tasks_execution_pauses SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;
