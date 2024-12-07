# **Análisis de Oferta y Demanda en la Educación Básica Especial (EBE)**  

Este proyecto se enfoca en evaluar la capacidad del sistema educativo para atender a estudiantes con necesidades educativas especiales asociadas a discapacidades, identificando brechas entre la oferta y la demanda en la modalidad de Educación Básica Especial (EBE).  

## **Objetivos Principales**  
- **Identificar Brechas**: Analizar la relación entre la oferta de vacantes, servicios especializados y la población estudiantil con discapacidad.  
- **Fortalecer la Planificación**: Proveer datos y evidencias para mejorar la asignación de recursos en instituciones educativas y servicios de apoyo como el SAANEE.  
- **Promover la Inclusión**: Generar estrategias que garanticen accesibilidad, equidad y calidad educativa para estudiantes con discapacidad.  

## **Componentes del Análisis**  
1. **Oferta Educativa**: Infraestructura accesible, recursos humanos especializados y servicios como SAANEE.  
2. **Demanda Educativa**: Población estudiantil objetivo registrada, tipo y grado de discapacidad, y necesidades específicas.  
3. **Indicadores Clave**:  
   - Proporción de vacantes por estudiante.  
   - Porcentaje de instituciones accesibles.  
   - Ratio estudiantes/docentes especializados.  

## **Impacto**  
Este análisis busca contribuir al diseño de políticas educativas inclusivas que respondan a las necesidades reales de los estudiantes con discapacidad, garantizando su derecho a una educación de calidad en condiciones de equidad y accesibilidad.  

---

## **Organización de la Información**  
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
