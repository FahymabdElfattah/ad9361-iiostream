#include "iiostream-common.h"
#include <iio/iio.h>
#include <iio/iio-debug.h>
#include <fftw3.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define SAMPLE_RATE 2500000  // 2.5 MS/s


static bool stop = false;

void stop_stream(void)
{
    stop = true;
}

void stream(size_t rx_sample, size_t tx_sample, size_t block_size,
            struct iio_stream *rxstream, struct iio_stream *txstream,
            const struct iio_channel *rxchn, const struct iio_channel *txchn)
{
    const struct iio_device *dev;
    const struct iio_context *ctx;
    const struct iio_block *rxblock;
    ssize_t nrx = 0;
    int N = 1024;  // Number of samples for FFT (make sure it fits in your block size)

    fftw_complex *in, *out;
    fftw_plan p;

    // Allocate FFTW arrays and plan
    in = (fftw_complex*) fftw_malloc(sizeof(fftw_complex) * N);
    out = (fftw_complex*) fftw_malloc(sizeof(fftw_complex) * N);
    p = fftw_plan_dft_1d(N, in, out, FFTW_FORWARD, FFTW_ESTIMATE);

    FILE *file = fopen("fft_data.txt", "w");
    if (file == NULL) {
        printf("Error opening file!\n");
        exit(1);
    }

    dev = iio_channel_get_device(rxchn);
    ctx = iio_device_get_context(dev);

    while (!stop) {
        int16_t *p_dat, *p_end;
        ptrdiff_t p_inc;
        int index = 0;

        rxblock = iio_stream_get_next_block(rxstream);
        if (iio_err(rxblock)) {
            ctx_perror(ctx, iio_err(rxblock), "Unable to receive block");
            fftw_destroy_plan(p);
            fftw_free(in);
            fftw_free(out);
            fclose(file);
            return;
        }

        // Read data and fill FFT input
        p_inc = rx_sample;
        p_end = (int16_t*) iio_block_end(rxblock);
        for (p_dat = (int16_t*) iio_block_first(rxblock, rxchn); p_dat < p_end && index < N;
             p_dat += p_inc / sizeof(*p_dat), index++) {
            in[index][0] = p_dat[0];  // Real part
            in[index][1] = p_dat[1];  // Imaginary part, assumes complex input
        }

        // Execute FFT
        fftw_execute(p);

        // Output the frequency domain data to file
        for (int i = 0; i < N / 2; i++) {  // Use N/2 for the meaningful part of FFT of a real signal
            double freq = i * SAMPLE_RATE / N;  // Calculate frequency bin
            double magnitude = sqrt(out[i][0] * out[i][0] + out[i][1] * out[i][1]);
            fprintf(file, "%f, %f\n", freq, magnitude);  // Write frequency and magnitude
        }


        /* WRITE: Get pointers to TX buf and write IQ to TX buf port 0 */
		p_inc = tx_sample;
		p_end = iio_block_end(txblock);
		for (p_dat = iio_block_first(txblock, txchn); p_dat < p_end;
		     p_dat += p_inc / sizeof(*p_dat)) {
			p_dat[0] = 0; /* Real (I) */
			p_dat[1] = 0; /* Imag (Q) */
		}

		nrx += block_size / rx_sample;
		ntx += block_size / tx_sample;
		ctx_info(ctx, "\tRX %8.2f MSmp, TX %8.2f MSmp\n", nrx / 1e6, ntx / 1e6);
    }

    fftw_destroy_plan(p);
    fftw_free(in);
    fftw_free(out);
    fclose(file);
}
