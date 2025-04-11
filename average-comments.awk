# Awk script to count average

# Copyright (C) 2025 Embecosm Limited
# Contributor Jeremy Bennett <jeremy.bennett@embecosm.com>

# SPDX-License-Identifier: GPL-3.0-or-later

# Invoke as awk -f average-comments.awk < <input file>

# The data has the form
# - PR ID (begins PR_)
# - PR creation date
# - PR close date
# - PR status
# - Comment ID (begins IC_)
# - Comment creation date
#   (above two lines repeat 0 or more times)

# We process with a simple state machine
# - EXPECT_COMMENT_OR_PR_ID: expecting PR ID
#   - if PR ID dump any data and goto EXPECT_PR_CREATE_DATE
#   - else if comment ID increment comment count and goto EXPECT_COMMENT_DATE
#   - else reset and goto EXPECT_COMMENT_OR_PR_ID
# - EXPECT_PR_CREATE_DATE: expecting PR creation date
#   - if not date, reset and goto EXPECT_COMMENT_OR_PR_ID
#   - else goto EXPECT_PR_CLOSE_DATE
# - EXPECT_PR_CLOSE_DATE: expecting PR close date
#   - if not date, reset and goto EXPECT_COMMENT_OR_PR_ID
#   - else record year and goto EXPECT_PR_STATE
# - EXPECT_PR_STATE: expecting something that is not a date
#   - if not MERGED, then reset
#   - goto EXPECT_COMMENT_OR_PR_ID
# - EXPECT_COMMENT_DATE: expecting comment date
#   - if not date, reset
#   - goto EXPECT_COMMENT_OR_PR_ID

# The data we dump allows us to work out the average at the end
# - count of number of merge PRs
# - total of number of comments

BEGIN {
    # State variables
    EXPECT_COMMENT_OR_PR_ID = 0
    EXPECT_PR_CREATE_DATE = 1
    EXPECT_PR_CLOSE_DATE = 2
    EXPECT_PR_STATE = 3
    EXPECT_COMMENT_DATE = 4
    # Global variables
    state = EXPECT_COMMENT_OR_PR_ID
    month = 0
    num_comments = 0
}

# Two patterns for EXPECT_COMMENT_OR_PR_ID
(/^PR_/ || /^MDE[^=]+$/) && (state == EXPECT_COMMENT_OR_PR_ID) {
    if (month != 0) {
	if (month in tot_merged) {
	    tot_merged[month] += 1
	    tot_comments[month] += num_comments
	} else {
	    tot_merged[month] = 1
	    tot_comments[month] = num_comments
	}
    }
    have_data = 1
    num_comments = 0
    state = EXPECT_PR_CREATE_DATE
    next
}

(/^IC_/ || /^MDE.+==$/) && (state == EXPECT_COMMENT_OR_PR_ID) {
    num_comments += 1
    state = EXPECT_COMMENT_DATE
    next
}

/[12][[:digit:]]{3}-/ && (state == EXPECT_PR_CREATE_DATE) {
    state = EXPECT_PR_CLOSE_DATE
    next
}

/[12][[:digit:]]{3}-/ && (state == EXPECT_PR_CLOSE_DATE) {
    y = substr($0, 1, 4)
    m = substr($0, 6, 2)
    month = (y m)
    state = EXPECT_STATE
    next
}

/[[:upper:]]+/ && (state == EXPECT_STATE) {
    if ($0 == "CLOSED") {
	# Silently record as closed
	if (month in tot_closed) {
	    tot_closed[month] += 1
	} else {
	    tot_closed[month] = 1
	}
	month = 0
    } else if ($0 != "MERGED") {
	printf "Unexpected state: %d: %s\n", state, $0
	month = 0
    }
    state = EXPECT_COMMENT_OR_PR_ID
    next
}

/[12][[:digit:]]{3}-/ && (state == EXPECT_COMMENT_DATE) {
    state = EXPECT_COMMENT_OR_PR_ID
    next
}

{
    printf "Unexpected state %s and input %s\n", state, $0
    state = EXPECT_COMMENT_OR_PR_ID
    next
}

END {
    # Capture the final data point
    if (month != 0) {
	if (month in tot_merged) {
	    tot_merged[month] += 1
	    tot_comments[month] += num_comments
	} else {
	    tot_merged[month] = 1
	    tot_comments[month] = num_comments
	}
    }

    # Dump the results
    PROCINFO["sorted_in"] = "@ind_str_asc"
    printf "%s,%s,%s,%s\n", "Date", "Closed PRs", "Merged PRs", \
	"Average comments"
    for (month in tot_merged) {
	y = substr(month, 1, 4)
	m = substr(month, 5, 2)
	if (tot_merged[month] != 0) {
	    average = tot_comments[month] / tot_merged[month]
	} else {
	    average = 0
	}
	printf "%s-%s-01,%d,%d,%f\n", y, m, tot_closed[month], \
	    tot_merged[month], average
    }
}
