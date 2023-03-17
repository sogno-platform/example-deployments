if [ "$DPSIM_SIMULATION_LOOP" = true ]; then
    while true; do
        python "$DPSIM_SIMULATION_FILE"
    done
else
    python "$DPSIM_SIMULATION_FILE"
fi