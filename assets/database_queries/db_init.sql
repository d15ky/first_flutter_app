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

CREATE TABLE task_executions(
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
CREATE TRIGGER updated_at_task_executions_trigger
AFTER UPDATE ON task_executions
BEGIN
   UPDATE task_executions SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

CREATE TABLE task_executions_pauses(
    id INTEGER PRIMARY KEY, 
    task_execution_id INTEGER, 
    start_time DATETIME, 
    end_time DATETIME, 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    FOREIGN KEY (task_execution_id) REFERENCES task_executions(id)
);
CREATE TRIGGER updated_at_task_executions_pauses_trigger
AFTER UPDATE ON task_executions_pauses
BEGIN
   UPDATE task_executions_pauses SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;
