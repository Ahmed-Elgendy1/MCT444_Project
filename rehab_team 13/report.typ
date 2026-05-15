#set page(
  paper: "a4",
  margin: (top: 2.0cm, bottom: 2.0cm, left: 2.2cm, right: 2.2cm),
  numbering: "1",
)
#set text(font: "Libertinus Serif", size: 11pt, lang: "en")
#set par(justify: true, first-line-indent: 0.35cm, leading: 0.36em)

#show heading.where(level: 1): it => [
  #v(0.8em)
  #text(size: 16pt, weight: "bold")[#it.body]
  #v(0.2em)
]
#show heading.where(level: 2): it => [
  #v(0.5em)
  #text(size: 12.5pt, weight: "bold")[#it.body]
  #v(0.1em)
]

#align(center)[
  #v(1.5cm)
  #text(size: 18pt, weight: "bold")[Faculty of Engineering]
  #v(0.15cm)
  #text(size: 16pt)[Ain Shams University]
  #v(1.4cm)
  #text(size: 21pt, weight: "bold")[Closed-Loop Musculoskeletal Modelling and Simulation]
  #v(0.2cm)
  #text(size: 15pt)[Below-Knee Prosthetic Jumping Analysis, Ground Reaction Forces, and Actuator Sizing]
  #v(0.9cm)
  #text(size: 12pt)[Course: MCT444 – Mechatronics in Rehabilitation Technology]
  #v(0.1cm)
  #text(size: 12pt)[Course code: MCT444]
  #v(0.1cm)
  #text(size: 12pt)[Teaching assistant: Hamdy Osama]
  #v(0.6cm)
  #text(size: 14pt, weight: "bold")[Team 13]
  #v(0.6cm)
  #table(
    columns: (1fr, 0.7fr),
    inset: 6pt,
    align: (left, center),
    stroke: 0.8pt + gray,
    fill: (x, y) => if y == 0 { luma(235) } else { white },
    [*Team member*], [*ID*],
    [Ahmed Osama Ahmed], [2101119],
    [Adham Waleed Gamal], [2100451],
    [Mohamed alaa abdelkarim], [2100392],
    [Mohamed tarek abdelwahab], [2100287],
    [Marwan Mahmoud Gaddallah], [2100771],
    [Omar Khaled Ahmed], [2100705],
  )
  #v(1.0cm)
  #text(size: 11pt)[Report date: 14 May 2026]
]

#pagebreak()

= Abstract

This report documents the complete workflow used for a lower-limb rehabilitation project based on OpenSim. The study focuses on the biomechanics of a vertical jumping motion and its application to below-knee prosthetic design. The jumping motion is decomposed into six distinct phases — standing, squat loading, push-off, flight, landing, and recovery — and each phase is analyzed in terms of joint kinematics, ground reaction forces (GRF), inverse-dynamics moments, and muscle activation patterns. The analysis provides the engineering basis for sizing prosthetic actuators at the knee and ankle joints.

The healthy model produces a peak vertical GRF exceeding 2× body weight during push-off, and the inverse-dynamics analysis reveals peak right-knee and right-ankle moments of 5.77 N·m and 1.61 N·m respectively. With a 1.5 safety factor, the design torque targets become 8.66 N·m at the knee and 2.41 N·m at the ankle. These quantities, together with the angular velocity and power profiles, form the primary actuator sizing deliverables.

= 1. Project Context

The project is built around a below-knee prosthetic concept integrated into an OpenSim musculoskeletal workflow. The practical aim is to understand how a prosthetic knee motor and ankle motor should be sized for a jumping task, how ground reaction forces distribute across the jump cycle, and how the resulting system compares with a healthy biological model.

The healthy reference model is the standard OpenSim gait2392-style model used for lower-limb biomechanical analysis. For this project, the healthy model was used as the baseline for a bilateral vertical jumping motion. The prosthetic model was derived from the healthy model by removing the biological function below the knee on the right side and introducing simplified prosthetic actuation.

The main deliverables generated during the project are:

- Jumping motion phase decomposition and kinematic analysis.
- Ground reaction force profiles (vertical and horizontal).
- Inverse-dynamics joint moment analysis for the right leg.
- Muscle activation and force patterns during jumping.
- Prosthetic actuator sizing from healthy inverse-dynamics peaks.
- Healthy-vs-prosthetic comparison for torque replay validation.

#pagebreak()

= 2. Jumping Motion Description

The jumping motion is a bilateral vertical jump lasting 2.5 seconds, sampled at 100 Hz (251 frames). The motion is synthesized to follow realistic biomechanical patterns for a countermovement jump and is divided into six distinct phases.

#figure(
  image("report_plots/phase_timeline.png", width: 100%),
  caption: [Phase timeline of the jumping motion showing all six phases from 0.0 s to 2.5 s.],
)

== 2.1 Phase Descriptions

*Phase 1 — Standing (0.0 – 0.5 s):* The model is in a neutral upright posture. All joint angles are zero, pelvis height is at the standing value of 0.93 m. This phase establishes the baseline configuration and allows the simulation to stabilize.

*Phase 2 — Squat / Loading (0.5 – 1.0 s):* The model descends into a deep squat using a smooth S-curve (Hermite smoothstep) transition. The hip flexes to 45°, the knee flexes to −90° (deep squat), and the ankle dorsiflexes to 45°. The lumbar spine extends to −30° to maintain the center of mass over the feet. The pelvis drops to its minimum height of 0.72 m. This countermovement phase stores elastic energy in the muscles and tendons.

*Phase 3 — Push-off (1.0 – 1.2 s):* This is the explosive propulsion phase. All joints rapidly extend: the hip and knee return toward neutral while the ankle plantarflexes to −30° (toe-off). The pelvis rises quickly from 0.72 m to 1.05 m. The ground reaction force reaches its peak during this phase as the body accelerates upward. This is the shortest and most dynamically intense phase (0.2 s).

*Phase 4 — Flight (1.2 – 1.5 s):* The model is airborne. The pelvis reaches a peak height of 1.30 m at approximately 1.35 s. During flight, the knees tuck slightly (−40° peak) while the ankle remains plantarflexed at −30°. The ground reaction force is approximately zero during this phase (equal to body weight in the simulation since it is a free-body analysis).

*Phase 5 — Landing (1.5 – 1.8 s):* The model absorbs the impact of landing. The joints return to the deep-squat configuration: hip at 45°, knee at −90°, ankle at 45°. The pelvis descends back to 0.72 m. The GRF shows a second peak as the body decelerates. This phase is critical for prosthetic design because the landing loads are often the highest mechanical demand on the actuators.

*Phase 6 — Recovery (1.8 – 2.5 s):* The model gradually returns to the upright standing posture over 0.7 s. All joints smoothly return to zero, and the pelvis rises back to 0.93 m. This is the longest phase and represents the transition back to quiet standing.

#pagebreak()

= 3. Kinematic Analysis

The joint kinematics capture the angular trajectories of the three primary lower-limb joints during the jump. The following figures show the right-leg joint angles, the pelvis vertical trajectory, and the angular velocities.

== 3.1 Joint Angles

#figure(
  image("report_plots/joint_kinematics.png", width: 100%),
  caption: [Right leg joint kinematics during the jump. Top: hip flexion, Middle: knee angle, Bottom: ankle angle. Phase boundaries are annotated.],
)

The kinematic data confirms the phase structure. The hip and knee move symmetrically (the knee angle is approximately twice the hip angle in magnitude due to the geometric constraint of keeping the feet under the hips). The ankle transitions from dorsiflexion during the squat to plantarflexion during push-off and flight.

== 3.2 Center of Mass Trajectory

#figure(
  image("report_plots/pelvis_height.png", width: 100%),
  caption: [Pelvis (center of mass) vertical trajectory. The dashed line shows the standing height. Peak flight height reaches 1.30 m.],
)

The pelvis height curve clearly shows the countermovement dip (0.72 m minimum), the rapid rise during push-off, and the parabolic flight trajectory with an apex at 1.30 m. The landing phase mirrors the push-off in reverse, and the recovery returns the pelvis to the initial standing height.

#pagebreak()

== 3.3 Angular Velocities

#figure(
  image("report_plots/angular_velocities.png", width: 100%),
  caption: [Right leg joint angular velocities computed by finite differencing the kinematic data. The push-off and landing phases show the highest angular rates.],
)

The angular velocity plots are essential for actuator sizing because motor speed requirements are determined by the peak angular velocity at each joint. The push-off phase (1.0 – 1.2 s) produces the highest angular velocities at all three joints, which means this is the phase where both torque and speed must be simultaneously available from the actuators.

#pagebreak()

= 4. Ground Reaction Force Analysis

Ground reaction forces (GRF) represent the forces exerted by the ground on the body during the jump. In this analysis, the GRF is extracted from the inverse-dynamics output, specifically from the `pelvis_ty_force` (vertical) and `pelvis_tx_force` (horizontal) columns. These represent the net external forces required to produce the observed motion.

== 4.1 Vertical and Horizontal GRF

#figure(
  image("report_plots/ground_reaction_forces.png", width: 100%),
  caption: [Ground reaction forces during the jump. Top: vertical GRF with body weight reference. Bottom: horizontal GRF. The vertical GRF exceeds body weight during push-off and landing.],
)

The vertical GRF pattern is characteristic of a countermovement jump:

- During *standing* (0.0 – 0.5 s), the vertical GRF equals body weight (~737 N).
- During the *squat/loading* phase, the GRF initially decreases slightly as the body descends, then increases as the muscles decelerate the downward motion.
- During *push-off*, the GRF rises sharply above body weight as the muscles generate the propulsive force needed for takeoff.
- During *flight*, the GRF should theoretically be zero (in this model, it reflects the residual pelvis forces from the inverse dynamics).
- During *landing*, a second GRF peak appears as the body decelerates from the flight speed.
- During *recovery*, the GRF gradually returns to body weight.

== 4.2 Normalized GRF

#figure(
  image("report_plots/grf_normalized.png", width: 100%),
  caption: [Vertical GRF normalized to body weight. Values above 1.0 indicate net upward acceleration.],
)

The normalized GRF is particularly useful for comparing jump performance across subjects of different body mass. In this simulation, the peak GRF during push-off and landing reaches approximately 1.5–2× body weight, which is consistent with literature values for countermovement jumps.

#pagebreak()

= 5. Inverse Dynamics Analysis

The inverse-dynamics analysis computes the net joint moments required to produce the observed motion. For the below-knee prosthetic design, the right knee and right ankle moments are the critical design quantities.

== 5.1 Right Leg Joint Moments

#figure(
  image("report_plots/id_moments.png", width: 100%),
  caption: [Right leg inverse-dynamics moments for the hip, knee, and ankle. Peak values are annotated. The knee moment shows the largest magnitude and reverses sign during the jump cycle.],
)

Key observations from the inverse-dynamics results:

- The *knee moment* is the largest in magnitude, with a peak absolute value of 5.77 N·m occurring during the push-off phase. The knee moment reverses sign during the cycle, indicating that the knee alternates between producing (extension) and absorbing (flexion) torque. This bidirectional behavior is critical for actuator selection — the motor must handle four-quadrant operation.

- The *ankle moment* peaks at 1.61 N·m and remains mostly positive (plantarflexion) throughout the active phases. The ankle provides push-off support and stabilizes the lower limb during landing.

- The *hip moment* shows moderate values and is dominated by the hip flexor/extensor muscles controlling trunk lean.

== 5.2 Bilateral Comparison

#figure(
  image("report_plots/bilateral_moments.png", width: 100%),
  caption: [Bilateral comparison of knee and ankle moments. The right and left sides are nearly identical due to the symmetric jump motion.],
)

The bilateral comparison confirms that the jumping motion is symmetric. This validates the use of the right-side inverse-dynamics data for prosthetic sizing, as both legs share the same loading pattern.

#pagebreak()

= 6. Muscle Activation and Force Analysis

The static optimization results provide insight into which muscles are active during each phase of the jump and what forces they produce. This information is important for understanding the biological baseline that the prosthetic actuators must replicate.

== 6.1 Muscle Activations

#figure(
  image("report_plots/muscle_activations.png", width: 100%),
  caption: [Right leg muscle activations grouped by functional category. Quadriceps and plantarflexors show the highest activations during push-off and landing.],
)

The activation patterns show that:

- *Quadriceps* (vastus medialis, intermedius, lateralis, and rectus femoris) are heavily activated during the squat and push-off phases, consistent with their role as knee extensors.
- *Hamstrings* (semimembranosus, semitendinosus, biceps femoris) activate during the loading phase to control hip flexion and knee flexion speed.
- *Plantarflexors* (gastrocnemius and soleus) activate strongly during push-off to generate the ankle plantarflexion torque needed for takeoff.
- *Dorsiflexors* (tibialis anterior) activate during the flight and early landing phases to prepare the foot for ground contact.

== 6.2 Muscle Forces

#figure(
  image("report_plots/muscle_forces.png", width: 100%),
  caption: [Key right leg muscle forces from static optimization. The vastus group and soleus dominate force production during the active jump phases.],
)

The force plot quantifies the mechanical demand on individual muscles. The vastus medialis produces the largest forces during the squat and push-off phases, followed by the soleus and gastrocnemius during push-off. These forces represent the biological benchmark that the prosthetic knee and ankle actuators must match in terms of joint moment production.

#pagebreak()

= 7. Metabolic Analysis

The healthy metabolic output from the OpenSim probe reporter provides the total metabolic rate of the model during the jump.

#figure(
  image("report_plots/metabolic_rate.png", width: 100%),
  caption: [Healthy model total metabolic rate during the jump. The metabolic rate reflects the whole-body energy expenditure and changes with jump phase.],
)

The metabolic rate remains high and fairly smooth across the jump window, which is expected for a whole-body metabolic measure. It dips near the middle of the cycle and rises again, reflecting the changing muscular effort during the jump and recovery phases. The integrated metabolic total over the 2.5 s window is 382.06 in the probe reporter's native units.

#pagebreak()

= 8. Prosthetic Model and Torque Replay

The prosthetic model was derived from the healthy gait model by replacing the right below-knee biological structure with simplified torque-driven actuation. A `PrescribedController` applies the stored torque histories for the prosthetic knee and ankle motors.

#figure(
  image("report_plots/prosthetic_comparison.png", width: 100%),
  caption: [Healthy metabolic rate (top) versus prosthetic actuator torque commands (bottom). The prosthetic torques peak during the push-off and landing phases.],
)

The comparison shows that the prosthetic actuator torques are concentrated in the same phases as the healthy metabolic demand — primarily during push-off and landing. This confirms that the prosthetic design targets the correct time windows for peak mechanical demand.

#pagebreak()

= 9. Actuator Sizing

Motor sizing is one of the most important design outputs of the project. The sizing uses the peak absolute joint moments from the healthy inverse-dynamics analysis, scaled by a safety factor.

== 9.1 Sizing Rule

The sizing rule used in the project is:

$ tau_"design" = "SF" times max |tau(t)| $

where SF = 1.5 is the safety factor. This gives a conservative first-pass design torque for motor shortlisting before detailed gearbox and thermal analysis.

== 9.2 Peak Moments and Design Targets

The peak healthy right-side moments extracted from the inverse-dynamics file are:

- Right knee peak absolute moment: *5.773651 N·m* at 1.03 s (during push-off).
- Right ankle peak absolute moment: *1.608040 N·m* at 1.47 s (during landing).

#table(
  columns: (2.3fr, 1.3fr, 1.3fr, 1.4fr),
  inset: 6pt,
  align: (left, right, right, right),
  stroke: 0.7pt + gray,
  fill: (x, y) => if y == 0 { luma(235) } else { white },
  [*Actuator*], [*Peak moment*], [*Safety factor*], [*Design peak*],
  [Right knee motor], [5.774 N·m], [1.5], [8.660 N·m],
  [Right ankle motor], [1.608 N·m], [1.5], [2.412 N·m],
)

== 9.3 Sizing Visualization

#figure(
  image("report_plots/actuator_sizing.png", width: 88%),
  caption: [Prosthetic actuator sizing bar chart showing the raw peak moment and the design target after applying the 1.5 safety factor.],
)

The knee motor needs substantially more torque capacity than the ankle motor. The knee absorbs and redistributes large inertial and support loads during the squat and push-off phases, while the ankle moment is smaller but sustained. In practical terms, the knee actuator will dominate the gearbox and motor envelope, while the ankle actuator can be lighter and more compact.

== 9.4 Torque and Power Profiles

#figure(
  image("report_plots/actuator_torque_power.png", width: 100%),
  caption: [Actuator torque and power time profiles for the knee and ankle. Power = torque × angular velocity. The push-off and landing phases dominate the power demand.],
)

The power profiles show when the actuators must deliver peak mechanical output. The knee power peaks during push-off (positive work) and landing (negative/absorbing work). The ankle power is concentrated in the push-off phase. These profiles are essential for selecting motors with adequate continuous and peak power ratings.

#pagebreak()

= 10. Motor-Selection Notes

The sizing result is a first-pass motor specification, not a final procurement decision. A real motor choice should consider at least four layers of validation:

- *Torque margin:* the motor must continuously exceed the design peak torque.
- *Speed margin:* the motor must sustain the angular velocity required by the joint trajectory.
- *Thermal margin:* the actuator must survive repeated cycles without overheating.
- *Drive margin:* the gearbox and controller must fit within the mechanical and electrical envelope.

For the knee, the key requirement is torque. The 8.66 N·m target is the design peak after safety factor, and it should be treated as the minimum shortlisting value. For the ankle, the 2.41 N·m target is modest in comparison, but the angular velocity and power profiles show that the ankle still participates significantly in the overall motion.

#table(
  columns: (2.2fr, 1.6fr, 1.6fr),
  inset: 6pt,
  align: (left, right, right),
  stroke: 0.7pt + gray,
  fill: (x, y) => if y == 0 { luma(235) } else { white },
  [*Joint*], [*Peak requirement*], [*Design target*],
  [Right knee], [5.774 N·m], [8.660 N·m],
  [Right ankle], [1.608 N·m], [2.412 N·m],
)

From a design-safety standpoint, a slightly oversized motor is usually preferable to an undersized one, because the report's torque targets are derived from a single motion case. Additional tasks such as stair ascent, landing transients, or perturbation recovery could produce larger peaks than the jump motion alone.

#pagebreak()

= 11. Discussion

The project workflow demonstrates that OpenSim can support a complete rehabilitation-design chain: healthy reference motion, kinematic decomposition, ground reaction force analysis, inverse-dynamics extraction, muscle activation profiling, and actuator sizing. The strongest aspect of the workflow is the way it keeps all analyses linked to the same motion window and phase structure.

Key findings from the analysis:

+ The jumping motion naturally decomposes into six phases, with the push-off (1.0 – 1.2 s) and landing (1.5 – 1.8 s) phases being the most mechanically demanding.
+ The vertical GRF exceeds body weight during push-off and landing, reaching approximately 1.5–2× BW.
+ The knee moment is the dominant joint-level quantity (5.77 N·m peak), requiring the highest torque capacity from the prosthetic actuator.
+ The ankle moment is smaller (1.61 N·m peak) but requires sustained output and careful power management.
+ Muscle activations confirm that the quadriceps and plantarflexors are the primary force generators during the jump.
+ The bilateral symmetry of the motion validates using right-side data for prosthetic sizing.

Limitations of the current analysis include:

- The motion is synthetically generated rather than captured from motion capture data.
- The GRF is derived from inverse dynamics rather than from a force plate measurement.
- The actuator sizing uses peak moments with a simple safety factor; a more detailed analysis would include duty-cycle thermal modeling.
- The metabolic rate is a model-based estimate, not a direct laboratory measurement.

For the next iteration, the project could include a gear-ratio study, a thermal model for long-duration use, a motion-tracking error metric between the prosthetic replay and the target motion, and validation against experimental force plate data.

= 12. Conclusion

This report documented a complete OpenSim-based workflow for a right below-knee prosthetic study focused on vertical jumping. The jumping motion was decomposed into six biomechanically distinct phases, and each phase was characterized through joint kinematics, ground reaction forces, inverse-dynamics moments, and muscle activation patterns.

The final actuator sizing targets from the healthy model are *8.660 N·m* for the right knee motor and *2.412 N·m* for the right ankle motor, using a 1.5 safety factor. The ground reaction force analysis revealed peak vertical forces of approximately 2× body weight during push-off and landing. The muscle activation analysis confirmed that the quadriceps and plantarflexors are the dominant force producers during the jump.

The knee must be selected for torque capacity and bidirectional operation, while the ankle must be checked for sustained power output and angular velocity requirements. Overall, the workflow is ready for the next design step: choosing actual motors and gearboxes, and validating the result in simulation or hardware.

= References

1. OpenSim gait2392 model and associated documentation used for lower-limb musculoskeletal modeling.
2. Ain Shams University Faculty of Engineering, MCT444 project brief and implementation plan.
3. Internal project outputs generated in this workspace: healthy metabolic probe results, inverse dynamics, prosthetic torque replay, and actuator sizing scripts.
4. Linthorne, N. P. (2001). Analysis of standing vertical jumps using a force platform. _American Journal of Physics_, 69(11), 1198-1204.

#pagebreak()

= Appendix A. Generated Files Used in This Report

The report was assembled from the following workspace outputs:

- `jumping_HEALTHY.mot` — Healthy jumping motion file (251 frames, 100 Hz).
- `inverse_dynamics.sto` — Inverse-dynamics joint moments.
- `3DGaitModel2392_ProbeReporter_probes.sto` — Metabolic probe data.
- `3DGaitModel2392_StaticOptimization_activation.sto` — Muscle activations.
- `3DGaitModel2392_StaticOptimization_force.sto` — Muscle forces.
- `3DGaitModel2392_controls.sto` — Prosthetic torque replay controls.
- `prosthetic_actuator_sizing.csv` — Actuator sizing results.

= Appendix B. Key Numerical Summary

#table(
  columns: (2.1fr, 1.6fr, 1.6fr),
  inset: 6pt,
  align: (left, right, right),
  stroke: 0.7pt + gray,
  fill: (x, y) => if y == 0 { luma(235) } else { white },
  [*Metric*], [*Value*], [*Note*],
  [Healthy metabolic total integral], [382.056], [From `metabolics_TOTAL`],
  [Standing body weight], [~737 N], [From `pelvis_ty_force`],
  [Peak vertical GRF], [~1.5–2× BW], [During push-off/landing],
  [Right knee peak moment], [5.774 N·m], [Healthy inverse dynamics],
  [Right ankle peak moment], [1.608 N·m], [Healthy inverse dynamics],
  [Right knee design torque], [8.660 N·m], [1.5 safety factor],
  [Right ankle design torque], [2.412 N·m], [1.5 safety factor],
  [Jump duration], [2.5 s], [251 frames at 100 Hz],
  [Peak pelvis height], [1.30 m], [During flight phase],
  [Standing pelvis height], [0.93 m], [Baseline],
  [Squat pelvis height], [0.72 m], [Minimum during loading],
)

= Appendix C. Report Plots Index

All figures in this report were generated by the script `generate_report_plots.py` from the analysis data files. The following plots are included:

+ Phase timeline (`phase_timeline.png`)
+ Joint kinematics (`joint_kinematics.png`)
+ Pelvis height trajectory (`pelvis_height.png`)
+ Angular velocities (`angular_velocities.png`)
+ Ground reaction forces (`ground_reaction_forces.png`)
+ Normalized GRF (`grf_normalized.png`)
+ Inverse dynamics moments (`id_moments.png`)
+ Bilateral moment comparison (`bilateral_moments.png`)
+ Muscle activations (`muscle_activations.png`)
+ Muscle forces (`muscle_forces.png`)
+ Metabolic rate (`metabolic_rate.png`)
+ Prosthetic comparison (`prosthetic_comparison.png`)
+ Actuator sizing (`actuator_sizing.png`)
+ Actuator torque and power (`actuator_torque_power.png`)