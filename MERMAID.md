```mermaid
flowchart TB
S[Start] --> A;
A[Enter Your Name]  --> B{Exixting User};
B --> |No| C(Enter name)
C --> D{Accept all Conditions}
D -->|No| A
```