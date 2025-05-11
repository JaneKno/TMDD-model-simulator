//Dua P, Hawkins E, van der Graaf PH. A Tutorial on Target-Mediated Drug Disposition (TMDD) Models. CPT Pharmacometrics Syst Pharmacol. 2015 Jun;4(6):324-37. doi: 10.1002/psp4.41. Epub 2015 Jun 15. PMID: 26225261; PMCID: PMC4505827.
// TMDD model
[PROB]
Two-Compartment TMDD Model with Binding in  Central Compartment

[PARAM]
// PK parameters
CL = 0.2       // Clearance (L/day)
V1 = 3.0       // Central volume (L)
Q = 0.5        // Intercompartmental clearance (L/day)
V2 = 2.0       // Peripheral volume (L)
ka = 1.0       // First-order absorption rate constant (1/day)
F1 = 1.0       // Bioavailability

// Rate constants
kint = 0.170    // Elimination of complex (1/day)
kdeg = 17.3    // Elimination of receptor (1/day)
koff = 169     // Dissociation rate (1/day)
kon = 30.2     // Binding rate (1/(nM*day))
Rc0 = 0.00657  // Initial receptor concentration (nM)
Vc = 0.04      // Volume of central compartment (L/kg)
MWlig = 150000 // Molecular weight of ligand (Da)

[CMT]
DEPOT   // Depot compartment for absorption
CENT    // Central compartment (for PK)
PERIPH  // Peripheral compartment (for PK)
R  // Free receptor
DR  // Drug-receptor complex

[MAIN]
double k10 = CL/V1;     // Elimination rate constant
double k12 = Q/V1;      // Distribution rate constant (central to peripheral)
double k21 = Q/V2;      // Distribution rate constant (peripheral to central)
double ksyn = kdeg * Rc0;  // Receptor synthesis rate (nM/day)

[ODE]
// Combined two-compartment PK with TMDD
dxdt_DEPOT = -ka * DEPOT;
dxdt_CENT = ka * DEPOT -(k10 + k12)*CENT + k21*PERIPH - kon*CENT*R + koff*DR;
dxdt_PERIPH = k12*CENT - k21*PERIPH;
dxdt_R = ksyn - kdeg*R - kon*CENT*R + koff*DR;
dxdt_DR = kon*CENT*R - koff*DR - kint*DR;

[TABLE]
double Lctot = CENT + DR;    // Total ligand concentration
double Rctot = R + DR;    // Total receptor concentration

[CAPTURE]
Lctot
Rctot