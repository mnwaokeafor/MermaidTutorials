```mermaid
flowchart TB
S[Start] --> A;
A[Enter your name]  --> B{Exixting User};
B --> |No| C(Enter name)
C --> D{Accept all Conditions}
D -->|No| A
```