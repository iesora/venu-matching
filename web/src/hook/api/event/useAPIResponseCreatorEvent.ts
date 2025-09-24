import { useMutation } from "react-query";
import { axiosInstance } from "@/utils/url";
import { AxiosError } from "axios";
import { jsonHeader } from "@/utils/url/header";
import { UseMutationOptions } from "react-query";
import { AcceptStatus } from "@/type";

export interface ResponseCreatorEventDto {
  creatorEventId: number;
  acceptStatus: AcceptStatus;
}

const responseCreatorEvent = async (
  body: ResponseCreatorEventDto
): Promise<{ message: string }> => {
  const headers = await jsonHeader;
  const response = await axiosInstance.patch(
    `/event/creator-event/response`,
    body,
    {
      headers,
    }
  );
  return response.data;
};

export const useAPIResponseCreatorEvent = (
  mutationOptions?: UseMutationOptions<
    { message: string },
    AxiosError,
    ResponseCreatorEventDto
  >
) => {
  return useMutation<{ message: string }, AxiosError, ResponseCreatorEventDto>(
    responseCreatorEvent,
    mutationOptions
  );
};
