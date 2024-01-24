/* SPDX-License-Identifier: GPL-2.0 */
/*
 * camss-csid-gen1.h
 *
 * Qualcomm MSM Camera Subsystem - CSID (CSI Decoder) Module Generation 1
 *
 * Copyright (C) 2021 Linaro Ltd.
 */
#ifndef QC_MSM_CAMSS_CSID_GEN1_H
#define QC_MSM_CAMSS_CSID_GEN1_H

#define DECODE_FORMAT_UNCOMPRESSED_6_BIT	0x0
#define DECODE_FORMAT_UNCOMPRESSED_8_BIT	0x1
#define DECODE_FORMAT_UNCOMPRESSED_10_BIT	0x2
#define DECODE_FORMAT_UNCOMPRESSED_12_BIT	0x3
#define DECODE_FORMAT_DPCM_10_6_10		0x4
#define DECODE_FORMAT_DPCM_10_8_10		0x5
#define DECODE_FORMAT_DPCM_12_6_12		0x6
#define DECODE_FORMAT_DPCM_12_8_12		0x7
#define DECODE_FORMAT_UNCOMPRESSED_14_BIT	0x8
#define DECODE_FORMAT_DPCM_14_8_14		0x9
#define DECODE_FORMAT_DPCM_14_10_14		0xa

#define PLAIN_FORMAT_PLAIN8	0x0 /* supports DPCM, UNCOMPRESSED_6/8_BIT */
#define PLAIN_FORMAT_PLAIN16	0x1 /* supports DPCM, UNCOMPRESSED_10/16_BIT */

#endif /* QC_MSM_CAMSS_CSID_GEN1_H */