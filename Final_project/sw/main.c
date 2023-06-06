#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include "system.h"
#include "io.h"
#include "sys/alt_irq.h"
#include "sys/alt_cache.h"
#include "altera_avalon_performance_counter.h"

#include "nn_weights.h"

#define TEST_IMAGE_SIZE 28*28

/* CNN_accelerator: Write registers */
#define START_IMAGE 0
#define START_WEIGHT 1
#define IMG_ADDR 2
#define IMG_LEN 3
#define WEIGHT_ADDR 4
#define WEIGHT_LEN 5

/* CNN_accelerator: Read registers */
#define PREDICTION 0

uint16_t test_image[TEST_IMAGE_SIZE];

// Place image in memory
void setup_mem(int len) {
	alt_dcache_flush_all();
	for(int i = 0; i < len; i++)
		IOWR_32DIRECT(&test_vals[i], 0, TEST_VAL);
}


/** Hardware accelerator CNN **/
void setup_CNN(){
	//IOWR
}

void accel_CNN_arr(uint32_t *arr, int size) {
	PERF_BEGIN(PERFORMANCE_COUNTER_0_BASE, 3);
	IOWR_32DIRECT(BITSWAP_ACC_0_BASE, 0, arr);
	IOWR_32DIRECT(BITSWAP_ACC_0_BASE, 1<<2, arr);
	IOWR_32DIRECT(BITSWAP_ACC_0_BASE, 1<<3, size);

	while(IORD_32DIRECT(BITSWAP_ACC_0_BASE, 0b11<<2) == 0);
	IOWR_32DIRECT(BITSWAP_ACC_0_BASE, 1<<3, 0);
	PERF_END(PERFORMANCE_COUNTER_0_BASE, 3);
}

int main(){
	uint16_t prediction = -1;

	/* test 1 value */

//	setup_mem(1);
//	accel_bitswap_arr(test_vals, 1);
//	res = verify_vals_sdram(1);
//	printf("Accelerator CNN (1 value): prediction = %d\n\n", prediciton);

	/* test 1000 values */

	setup_mem(1000);
	accel_CNN_arr(test_vals, 1000);
	printf("Accelerator CNN (1000 values) verify_vals result %d\n", res);

	PERF_STOP_MEASURING(PERFORMANCE_COUNTER_0_BASE);
	perf_print_formatted_report(PERFORMANCE_COUNTER_0_BASE, alt_get_cpu_freq(), 1, "Hardware acc.");
	return 0;
}

