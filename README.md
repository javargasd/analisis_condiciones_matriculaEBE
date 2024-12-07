# **Análisis de Oferta y Demanda en la Educación Básica Especial (EBE)**  

Este proyecto se enfoca en evaluar la capacidad del sistema educativo peruano para atender a estudiantes con necesidades educativas especiales asociadas a discapacidades, identificando brechas entre la oferta y la demanda en la modalidad de Educación Básica Especial (EBE).  

### **I. Objetivos Principales**  
- **Identificar Brechas**: Analizar la relación entre la oferta de vacantes, servicios especializados y la población estudiantil con discapacidad.  
- **Fortalecer la Planificación**: Proveer datos y evidencias para mejorar la asignación de recursos en instituciones educativas y servicios de apoyo como el SAANEE.  
- **Promover la Inclusión**: Generar estrategias que garanticen accesibilidad, equidad y calidad educativa para estudiantes con discapacidad.  

### **II. Componentes del Análisis**  
2.1. **Oferta de Plazas Educativas**:  
   - **Instituciones Potenciales**: IE que han atendido previamente a estudiantes con discapacidad y que, bajo este análisis, tienen la capacidad de seguir haciéndolo.  
   - **Disponibilidad de Plazas**: Número de vacantes habilitadas para estudiantes con discapacidad en cada IE.  
   - **Distribución Geográfica**: Ubicación de las IE en relación con la población estudiantil objetivo.  

2.2. **Demanda de Plazas Educativas**:  
   - **Población Objetivo**: Estudiantes entre 0 y 20 años con discapacidad registrados en la BIPED y que requieren atención educativa.  
   - **Características Específicas**: Necesidades derivadas del grado y tipo de discapacidad (leve, moderada, severa).  
   - **Necesidades de Cobertura**: Número de estudiantes en espera de una plaza educativa en su área geográfica.  

2.3. **Indicadores Clave**:  
   - **Proporción de Vacantes por Estudiante**: Relación entre la oferta total de vacantes disponibles y la población objetivo.  
   - **Cobertura de Instituciones Potenciales**: Porcentaje de IE identificadas que ofrecen plazas para estudiantes con discapacidad.  
   - **Déficit de Plazas**: Brecha entre la demanda estimada de plazas y las vacantes ofertadas por las IE en cada región.  

### **III. Organización de la Información**  
Las bases de datos disponibles en este repositorio corresponden al Módulo Complementario de SIGA en el periodo 2019-2024 con corte al 01/03/2024.  

```markdown
├── README.md                <- README principal.
├── Bases de datos
│   ├── input                <- Datos originales, datos inmutables sin ninguna transformación.
│   ├── output               <- Datos finales.
│   └── temp                 <- Datos intermedios que ya han sido transformados.
|   └── Codigos              <- Carpeta de códigos.
│            ├── '1. Definición de denominador.do'            
│            ├── '2. Definición de pago_agua.do'              
│            ├── '3. Definición de pago_luz.do'               
│            ├── '4. Definición de cumplimiento.do'           
│            ├── '5. Revisión de resultados finales.do'
│            └── '6. Visualización.do'
|
├── Documentos             <- Documentación del proyecto, ver detalles.
│
├── Referencias            <- Diccionarios de datos, manuales y material explicativo.
│
└── Reports                <- Análisis generado (HTML, PDF, LaTeX, etc.).
       └── figuras         <- Gráficos y figuras generados usados en los reports.         
```
### **IV. Impacto**  
Este análisis busca contribuir al diseño de políticas educativas inclusivas que respondan a las necesidades reales de los estudiantes con discapacidad, garantizando su derecho a una educación de calidad en condiciones de equidad y accesibilidad.  

---
