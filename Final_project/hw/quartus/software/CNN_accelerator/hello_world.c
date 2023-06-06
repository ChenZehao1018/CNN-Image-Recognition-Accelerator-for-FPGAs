#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include "system.h"
#include "io.h"
#include "sys/alt_irq.h"
#include "sys/alt_cache.h"
#include "altera_avalon_performance_counter.h"

#include "nn_weights.h"
#include "test_image.h"

#define TEST_IMAGE_SIZE 28*28
#define WEIGHT_SIZE 16*3 // 3 outputs, 16 weights per output
#define WAIT_TIME 50 // time to wait between commands

/* CNN_accelerator: Write registers */
#define START_IMAGE 0
#define START_WEIGHT 1*4
#define IMG_ADDR 2*4
#define IMG_LEN 3*4
#define WEIGHT_ADDR 4*4
#define WEIGHT_LEN 5*4

/* CNN_accelerator: Read registers */
#define PREDICTION 0

// Place image, begin image convolution, begin neurons, return result
uint32_t pred_image(uint16_t *test_image, uint32_t image_size, uint8_t waitTime){
	PERF_BEGIN(PERFORMANCE_COUNTER_0_BASE, 1);

	IOWR_32DIRECT(HW_ACCELERATOR_FOR_CNN_0_BASE, IMG_LEN, TEST_IMAGE_SIZE);
	IOWR_32DIRECT(HW_ACCELERATOR_FOR_CNN_0_BASE, IMG_ADDR, test_image);
	//Begin computation
	IOWR_32DIRECT(HW_ACCELERATOR_FOR_CNN_0_BASE, START_IMAGE, 1);
	for(int i=0; i<waitTime; i++);
	IOWR_32DIRECT(HW_ACCELERATOR_FOR_CNN_0_BASE, START_IMAGE, 0);

	IOWR_32DIRECT(HW_ACCELERATOR_FOR_CNN_0_BASE, WEIGHT_LEN, WEIGHT_SIZE);
	IOWR_32DIRECT(HW_ACCELERATOR_FOR_CNN_0_BASE, WEIGHT_ADDR, &nnWeights);
	IOWR_32DIRECT(HW_ACCELERATOR_FOR_CNN_0_BASE, START_WEIGHT, 1);
	for(int i=0; i<waitTime; i++);
	IOWR_32DIRECT(HW_ACCELERATOR_FOR_CNN_0_BASE, START_WEIGHT, 0);

	uint32_t prediciton = IORD_32DIRECT(HW_ACCELERATOR_FOR_CNN_0_BASE, PREDICTION);
	//Get prediction
//	uint32_t img_addr = IORD_32DIRECT(HW_ACCELERATOR_FOR_CNN_0_BASE, IMG_ADDR);
//	uint32_t img_len = IORD_32DIRECT(HW_ACCELERATOR_FOR_CNN_0_BASE, IMG_LEN);
//	uint32_t weight_addr = IORD_32DIRECT(HW_ACCELERATOR_FOR_CNN_0_BASE, WEIGHT_ADDR);
//	uint32_t weight_len = IORD_32DIRECT(HW_ACCELERATOR_FOR_CNN_0_BASE, WEIGHT_LEN);
//	uint32_t prediciton_0 = IORD_32DIRECT(HW_ACCELERATOR_FOR_CNN_0_BASE, 4);
//	uint32_t prediciton_1 = IORD_32DIRECT(HW_ACCELERATOR_FOR_CNN_0_BASE, 24);
//	uint32_t prediciton_2 = IORD_32DIRECT(HW_ACCELERATOR_FOR_CNN_0_BASE, 28);
//	printf("%lu\n",img_addr);
//	printf("%lu\n",img_len);
//	printf("%lu\n",weight_addr);
//	printf("%lu\n",weight_len);
//	printf("%lu\n",img_addr);
//	printf("pred0res%lu\n",prediciton_0);
//	printf("pred1res%lu\n",prediciton_1);
//	printf("pred2res%lu\n",prediciton_2);
	PERF_END(PERFORMANCE_COUNTER_0_BASE, 1);

	return prediciton;
}

uint8_t check_prediciton(uint32_t prediction, uint8_t label){
	printf("HW CNN predicts: %lu vs label: %u\n", prediction, label);
	return prediction == label;
}

int main(){
	//setup(weights_ptr): and weight addresses in avalon slave
	PERF_START_MEASURING(PERFORMANCE_COUNTER_0_BASE);
//	setup_weights(nnWeights, WEIGHT_SIZE);

	uint16_t prediction = -1;

	/* test 1 value */
	prediction = pred_image(testImage1, TEST_IMAGE_SIZE, WAIT_TIME);
	printf("HW CNN predicts: %d vs label: %d\n", prediction, testImage1Label);

	PERF_STOP_MEASURING(PERFORMANCE_COUNTER_0_BASE);
	perf_print_formatted_report(PERFORMANCE_COUNTER_0_BASE, alt_get_cpu_freq(), 1, "Hardware acc.");
	return 0;
}

