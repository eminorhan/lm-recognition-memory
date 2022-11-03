#!/bin/bash

#SBATCH --gres=gpu:a100:4
#SBATCH --cpus-per-task=16
#SBATCH --mem=492GB
#SBATCH --time=12:00:00
#SBATCH --job-name=train_gptj
#SBATCH --output=train_gptj_%A_%a.out
#SBATCH --array=0

module purge
module load cuda/11.6.2    

# which experiment
EXPT="expt1"

# grid
EXS=("seen_data_0" "seen_data_1" "seen_data_2" "seen_data_3")
LRS=(0.0001 0.00005 0.00003 0.00001)
BSS=(1 2 3)

# gpt-j-6b
MO="EleutherAI/gpt-j-6B"
for EX in "${EXS[@]}"
do
    for LR in "${LRS[@]}"
    do
        for BS in "${BSS[@]}"
        do
            SP="gpt_j_${EX}_${LR}_${BS}"
            accelerate launch --config_file /scratch/eo41/lm-recognition-memory/accelerate_config.yaml --num_cpu_threads_per_process 4 /scratch/eo41/lm-recognition-memory/train.py \
                --model_name_or_path ${MO} \
                --train_file "/scratch/eo41/lm-recognition-memory/data/recognition-memory-experimental-data/${EXPT}/${EX}.json" \
                --per_device_train_batch_size ${BS} \
                --learning_rate ${LR} \
                --output_dir "/scratch/eo41/lm-recognition-memory/models/${SP}" \
                --save_prefix ${SP} \
                --block_size 128 \
                --num_train_epochs 1 \
                --overwrite_cache
        done
    done
done

echo "Done"